Include HS.FHIRServer

Class isc.ateam.validation.FHIRValidation [ Abstract ]
{

Parameter SkipIfNoProfileKEY = "/FHIR/Validation/SkipIfNoProfile";

Parameter JavaGatewayPortKEY = "/FHIR/Validation/JavaGatewayPort";

Parameter JavaGatewayServerKEY = "/FHIR/Validation/JavaGatewayServer";

Parameter IGListKEY = "/FHIR/Validation/IGList";

Parameter TerminologyServerKEY = "/FHIR/Validation/TerminologyServer";

Parameter PatientProfileKEY = "/FHIR/Validation/PatientProfile";

ClassMethod validate(theResource As %DynamicObject)
{
	#dim skipIfNoProfile As %String = ##class(HS.Registry.Config).GetKeyValue(..#SkipIfNoProfileKEY)
	
	#dim noProfile As %Boolean = ('theResource.%IsDefined("meta") || 'theResource.meta.%IsDefined("profile") || (theResource.meta.profile.%Size() = 0))
	
	// skipIfNoProfile: only validate if profile is specified within the resource
	if +skipIfNoProfile && noProfile
	{
		quit
	}
	
	// default Patient profile
	#dim patientProfile As %String = ##class(HS.Registry.Config).GetKeyValue(..#PatientProfileKEY)
	
	#dim profileToValidateAgainst As %String = ""
	if noProfile 
			&& (theResource.resourceType = "Patient") 
			&& (patientProfile '= "")
	{
		set profileToValidateAgainst = patientProfile
	}
	
	// run validation
	#dim operationOutcome As %DynamicObject = ..validateAgainstProfile(theResource, profileToValidateAgainst)

	// in case of any severity=error issues --> assemble error status
	#dim errorStatus As %Status = $$$OK
	#dim iter As %Iterator.Object = operationOutcome.issue.%GetIterator()
	#dim issue As %DynamicObject
	while iter.%GetNext(.key, .issue) 
	{
		if (issue.severity = "error")
		{
			#dim oneError As %Status = $$$ERROR($$$GeneralError, issue.details.text, $$$OutcomeWithPath(400, "error", issue.code, issue.expression.%Get(0)))
			$$$FHIRAddError(errorStatus, oneError)
		}
	}

	$$$ThrowOnError(errorStatus)
}

/// Returns OperationOutcome resource
ClassMethod validateAgainstProfile(theResource As %DynamicObject, profileToValidateAgainst As %String = "") As %DynamicObject
{
	#dim javaGatewayPort As %String = ##class(HS.Registry.Config).GetKeyValue(..#JavaGatewayPortKEY)
	#dim javaGatewayServer As %String = ##class(HS.Registry.Config).GetKeyValue(..#JavaGatewayServerKEY)
	#dim igList As %String = ##class(HS.Registry.Config).GetKeyValue(..#IGListKEY)
	#dim terminologyServer As %String = ##class(HS.Registry.Config).GetKeyValue(..#TerminologyServerKEY)
	
	// check if Java Gateway is up
	#dim sc As %Status = ##class(%Net.Remote.Service).PingGateway(javaGatewayPort, javaGatewayServer)
	if $$$ISERR(sc)
	{
		// assuming this is local gateway, try to start it
		$$$ThrowOnError(##class(%Net.Remote.Service).StartGateway("%Java Server"))
		set sc = $$$OK
	}

	// connect to gateway
	#dim gw As %Net.Remote.Gateway = ##class(%Net.Remote.Gateway).%New()
	$$$ThrowOnError(gw.%Connect(javaGatewayServer, javaGatewayPort))
	
	// generate proxy class if it's not present
	if '$$$comClassDefined("isc.ateam.validation.JavaValidatorFacade")
	{
		do ##class(%Net.Remote.Java.JavaGateway).%ExpressImport("isc.ateam.validation.JavaValidatorFacade", javaGatewayPort, javaGatewayServer, $$$YES)
	}

	#dim jsonIn As %Stream.TmpBinary = ##class(%Stream.TmpBinary).%New()
	do theResource.%ToJSON(jsonIn)

	// run the validator
	#dim jsonOut As %Stream.Object = ""
	try
	{
		$$$FSLog("About to call Java validator...")
		set jsonOut = ##class(isc.ateam.validation.JavaValidatorFacade).validate(gw, igList, jsonIn, terminologyServer, profileToValidateAgainst)
	}
	catch ex
	{
		set sc = $get(%objlasterror)  // exception with Java stack here!
		if (sc = "") set sc = ex.AsStatus()
	}
	
	kill jsonIn
	$$$ThrowOnError(sc)

	#dim operationOutcome As %DynamicObject = {}.%FromJSON(jsonOut)
	quit operationOutcome
}

}


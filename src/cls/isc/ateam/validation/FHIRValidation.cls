Include HS.FHIRServer

Class isc.ateam.validation.FHIRValidation [ Abstract ]
{

Parameter SkipIfNoProfileKEY = "/FHIR/Validation/SkipIfNoProfile";

Parameter JavaGatewayPortKEY = "/FHIR/Validation/JavaGatewayPort";

Parameter JavaGatewayServerKEY = "/FHIR/Validation/JavaGatewayServer";

Parameter IGListKEY = "/FHIR/Validation/IGList";

Parameter TerminologyServerKEY = "/FHIR/Validation/TerminologyServer";

Parameter DefaultProfilePrefixKEY = "/FHIR/Validation/DefaultProfile/";

Parameter FhirVersionKEY = "/FHIR/Validation/FHIRVersion";

Parameter JavaGatewayNameKEY = "/FHIR/Validation/JavaGatewayName";

Parameter ConformanceAndTerminologyRESOURCES = {$lb("CapabilityStatement", "StructureDefinition", "OperationDefinition", "SearchParameter", "CompartmentDefinition", "ImplementationGuide", "CodeSystem", "ValueSet", "NamingSystem", "ConceptMap", "TerminologyCapabilities")};

ClassMethod validate(theResource As %DynamicObject, isValidateOperation As %Boolean = {$$$NO}, profileToValidateAgainst As %String = "")
{
	// if we are not in $validate operation context, then we might skip validation in certain situations
	if (isValidateOperation '= $$$YES)
	{
		// skip validation for conformance and terminology resource types
		if $listfind(..#ConformanceAndTerminologyRESOURCES, theResource.resourceType) quit
	
		// if the profile is not specified either as an argument or within the resource...
		if (profileToValidateAgainst = "") &&
				('theResource.%IsDefined("meta") 
					|| 'theResource.meta.%IsDefined("profile") 
					|| (theResource.meta.profile.%Size() = 0)
				)
		{
			// SkipIfNoProfile config: skip validation if no profile is specified within the resource
			if +##class(HS.Registry.Config).GetKeyValue(..#SkipIfNoProfileKEY) quit

			// get default profile(s) for the resource type (might not be configured)
			set profileToValidateAgainst = ##class(HS.Registry.Config).GetKeyValue(..#DefaultProfilePrefixKEY _ theResource.resourceType)
		}
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
	#dim fhirVersion As %String = ##class(HS.Registry.Config).GetKeyValue(..#FhirVersionKEY)
	
	// check if Java Gateway is up
	#dim sc As %Status = ##class(%Net.Remote.Service).PingGateway(javaGatewayPort, javaGatewayServer)
	if $$$ISERR(sc)
	{
		#dim javaGatewayName As %String = ##class(HS.Registry.Config).GetKeyValue(..#JavaGatewayNameKEY)
		if (javaGatewayName="") Throw $$$ERROR($$$GeneralError, "Missing Configuration Registry value for: " _ ..#JavaGatewayNameKEY)
		// assuming this is local gateway, try to start it
		$$$ThrowOnError(##class(%Net.Remote.Service).StartGateway(javaGatewayName))
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

	#dim jsonIn As %Stream.FileCharacter = ##class(%Stream.FileCharacter).%New()
	set jsonIn.TranslateTable = "UTF8"

	do theResource.%ToJSON(jsonIn)
	set jsonIn.TranslateTable = "RAW"

	#dim jsonInBin As %Stream.TmpBinary = ##class(%Stream.TmpBinary).%New()
	do jsonInBin.CopyFrom(jsonIn)
	kill jsonIn
	
	// memorize the current device
	#dim oldIO = $io
	#dim oldMnemonic As %String = ##class(%Device).GetMnemonicRoutine()
	#dim oldIORedirected As %Boolean = ##class(%Device).ReDirectIO()
	
	$$$FSLog("About to call Java validator...")
	
	// redirect std output to null device
	#dim dev As %String = $case($$$isWINDOWS, $$$YES:"//./nul", :"/dev/null")
	open dev
	use dev
	
	// run the validator
	#dim jsonOut As %Stream.Object = ""
	try
	{
		set jsonOut = ##class(isc.ateam.validation.JavaValidatorFacade).validate(gw, igList, jsonInBin, terminologyServer, profileToValidateAgainst, fhirVersion)
	}
	catch ex
	{
		set sc = $get(%objlasterror)  // exception with Java stack here!
		if (sc = "") set sc = ex.AsStatus()
	}
	close dev
	
	// revert back to normal
	if (oldMnemonic '= "")
	{
		use oldIO::("^"_oldMnemonic)
	}
	else 
	{
		use oldIO
	}
	do ##class(%Device).ReDirectIO(oldIORedirected)
	
	kill jsonInBin
	$$$ThrowOnError(sc)

	
	#dim jsonOutChar As %Stream.FileCharacter = ##class(%Stream.FileCharacter).%New()
	set jsonOutChar.TranslateTable = "RAW"

	do jsonOutChar.CopyFrom(jsonOut)
	kill jsonOut
	
	set jsonOutChar.TranslateTable = "UTF8"

	#dim operationOutcome As %DynamicObject = {}.%FromJSON(jsonOutChar)
	quit operationOutcome
}

}

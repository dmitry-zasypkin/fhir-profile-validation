Class isc.ateam.validation.FHIRResourceValidator Extends HS.FHIRServer.Util.ResourceValidator
{

Parameter MAJOR = {$System.Version.GetMajor()};

Parameter MINOR = {$System.Version.GetMinor()};

/// @API
/// ValidateResource validates a FHIR Resource.  If a validation error is found, a
/// compound %Status is thrown in a StatusException.  The compound %Status starts with a
/// $$$ValidationFailure code, followed by additional %Status objects for each detected
/// validation error.
Method ValidateResource(pResourceObject As %DynamicObject, pIsInTransaction As %Boolean = 0)
{
	// we don't want to call ##super if it's IRIS 2023.3 or newer
	
	if (+..#MAJOR < 2023) || ((..#MAJOR = 2023) && (+..#MINOR < 3))
	{
		// before 2023.3: this is just some basic validation
		do ##super(pResourceObject)
	}
	
	// it's FHIRBundleValidator that takes care of validating Bundle entries
	//   so here we skip validation if we are in transaction
	
	if (pIsInTransaction '= $$$YES)
	{
		// global variables %isFHIRValidateOperation and %FHIRValidateOperationProfileParam are set by isc.ateam.validation.FHIRValidateOperation class that implements $validate operation which respects 'profile' input parameter
		do ##class(isc.ateam.validation.FHIRValidation).validate(
			pResourceObject, 
			$get(%isFHIRValidateOperation), 
			$get(%FHIRValidateOperationProfileParam))
	}
}

}


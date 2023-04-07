Class isc.ateam.validation.FHIRResourceValidator Extends HS.FHIRServer.Util.ResourceValidator
{

/// @API
/// ValidateResource validates a FHIR Resource.  If a validation error is found, a
/// compound %Status is thrown in a StatusException.  The compound %Status starts with a
/// $$$ValidationFailure code, followed by additional %Status objects for each detected
/// validation error.
Method ValidateResource(pResourceObject As %DynamicObject, pIsInTransaction As %Boolean = 0)
{
	do ##super(pResourceObject)
	
	// it's FHIRBundleValidator that takes care of validating Bundle entries
	//   so here we skip validation if we are in transaction
	
	if (pIsInTransaction '= $$$YES)
	{
		do ##class(isc.ateam.validation.FHIRValidation).validate(pResourceObject, $get(%isFHIRValidateOperation), $get(%FHIRValidateOperationProfileParam))
	}
}

}


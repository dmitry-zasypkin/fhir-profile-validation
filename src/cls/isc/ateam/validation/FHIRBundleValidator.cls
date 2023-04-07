Class isc.ateam.validation.FHIRBundleValidator Extends HS.FHIRServer.Util.BundleValidator
{

ClassMethod ValidateBundle(pResourceObject As %DynamicObject, pFHIRVersion As %String)
{
	do ##super(pResourceObject, pFHIRVersion)

	do ##class(isc.ateam.validation.FHIRValidation).validate(pResourceObject)
}

}


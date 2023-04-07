Class isc.ateam.validation.FHIRCustomOperations Extends (isc.ateam.validation.FHIRValidateOperation, HS.FHIRServer.Storage.BuiltInOperations)
{

ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
	do ##super(pMap)
	do ##class(isc.ateam.validation.FHIRValidateOperation).AddSupportedOperations(pMap)
}

}


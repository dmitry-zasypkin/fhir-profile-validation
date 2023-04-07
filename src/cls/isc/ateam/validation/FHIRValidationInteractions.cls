Class isc.ateam.validation.FHIRValidationInteractions Extends HS.FHIRServer.Storage.Json.Interactions
{

Parameter ResourceValidatorClass = "isc.ateam.validation.FHIRResourceValidator";

Parameter BatchHandlerClass As %String = "isc.ateam.validation.FHIRBundleProcessor";

Parameter OperationHandlerClass As %String = "isc.ateam.validation.FHIRCustomOperations";

}


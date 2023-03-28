Class isc.ateam.fhir.validation.FHIRValidationInteractions Extends HS.FHIRServer.Storage.Json.Interactions
{

Parameter ResourceValidatorClass = "isc.ateam.fhir.validation.FHIRResourceValidator";

Parameter BatchHandlerClass As %String = "isc.ateam.fhir.validation.FHIRBundleProcessor";

}


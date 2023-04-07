Profile: MyBundle
Parent: Bundle
Description: "An example profile of the Bundle resource."
* type = http://hl7.org/fhir/bundle-type#transaction (exactly)
* entry ^slicing.discriminator.type = #type
* entry ^slicing.discriminator.path = "resource"
* entry ^slicing.rules = #closed
* entry contains Patient 1..1 and Observation 0..*
* entry[Patient].resource only MyPatient
* entry[Observation].resource only Observation

Instance: BundleExample
InstanceOf: MyBundle
Description: "An example of a bundle"
Usage: #example
* type = http://hl7.org/fhir/bundle-type#transaction
* entry[Patient].fullUrl = "urn:uuid:6a79bb01-6289-4665-a23c-f0f0704dd9d4"
* entry[Patient].resource = PatientExample
* entry[Patient].request.method = http://hl7.org/fhir/http-verb#POST
* entry[Patient].request.url = "Patient"
* entry[Observation].fullUrl = "urn:uuid:6a79bb01-6289-4665-a23c-f0f0704dd555"
* entry[Observation].resource.resourceType = "Observation"
* entry[Observation].resource.status = http://hl7.org/fhir/observation-status#final
* entry[Observation].resource.code = http://loinc.org#15074-8 "Glucose [Moles/volume] in Blood"
* entry[Observation].resource.subject.reference = "urn:uuid:6a79bb01-6289-4665-a23c-f0f0704dd9d4"
* entry[Observation].request.method = http://hl7.org/fhir/http-verb#POST
* entry[Observation].request.url = "Observation"
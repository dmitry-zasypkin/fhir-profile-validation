// This is a simple example of a FSH file.
// This file can be renamed, and additional FSH files can be added.
// SUSHI will look for definitions in any file using the .fsh ending.
Profile: MyPatient
Parent: Patient
Description: "An example profile of the Patient resource."
* name 1..* MS
* extension contains BirthSexExtension named birthsex 0..1

Alias: GENDER = http://terminology.hl7.org/CodeSystem/v3-AdministrativeGender
Alias: NULL = http://terminology.hl7.org/CodeSystem/v3-NullFlavor

ValueSet: BirthSex
Id: birthsex-valueset
Title: "Birth Sex"
Description: "Codes for assigning sex at birth"
* GENDER#M "Male"
* GENDER#F "Female"
* NULL#UNK "Unknown"

Extension: BirthSexExtension
Id: birthsex-extension
Title: "Birth Sex Extension"
Description: "A code classifying the person's sex assigned at birth"
* value[x] only code
* valueCode from BirthSex

Instance: PatientExample
InstanceOf: MyPatient
Description: "An example of a patient"
Usage: #example
* extension[birthsex-extension].valueCode = GENDER#F
* name
  * given = "Janette"
  * family = "Smith"
* maritalStatus = http://terminology.hl7.org/CodeSystem/v3-MaritalStatus#M "Married"

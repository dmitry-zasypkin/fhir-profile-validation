# fhir-profile-validation
Validating FHIR resources against profiles in FHIR Resource Repository of [InterSystems IRIS for Health](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls) 2022+.

## Docker Installation
1. Clone the repo into any local directory, e.g.:
	```
	$ git clone https://github.com/dmitry-zasypkin/fhir-profile-validation.git
	$ cd fhir-profile-validation
	```
2. If necessary, put your FHIR profiles (as well as any related FHIR conformance and terminology resources) into ```profile``` directory which initially contains several sample profiles.
3. If necessary, edit [.env](../main/.env) file to use the FHIR Terminology Server of your choice, or to change IRIS namespace or FHIR endpoint that will be created during installation.
4. Build the images and start containers: 
	```
	$ docker-compose build
	$ docker-compose up -d
	```

## Testing with Postman
1. Import [fhir-profile-validation.postman_collection.json](../main/postman/fhir-profile-validation.postman_collection.json) file into Postman.
	* Adjust ```url``` variable defined in the collection.
2. Use the requests from the Postman collection to validate Patient and Bundle resources by calling ```$validate``` operation, or by POSTing resources to FHIR Repository. 
<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231098465-75b0fa7e-f866-4a84-be9d-02b27b75d73e.png" alt="Postman Collection" width="250"/></p>




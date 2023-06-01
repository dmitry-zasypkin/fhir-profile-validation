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

## Host Installation
1. Install [InterSystems IRIS for Health](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls) 2022.1 or newer. Community Edition would be okay.
2. Install Java 11 JRE.
3. Clone the repo into any local directory (```C:\Git\fhir-profile-validation``` in this example):
	```
	C:\Git> git clone https://github.com/dmitry-zasypkin/fhir-profile-validation.git
	```
4. In IRIS terminal import [App.Installer](../main/Installer.cls) class into ```USER``` namespace:
	```
	XXX> zn "USER"
	USER> do $System.OBJ.Load("C:\Git\fhir-profile-validation\Installer.cls", "ck")
	```
5. Run [setup()](../main/Installer.cls#L4) method of ```App.Installer``` class passing it a number of parameters, e.g.:
	```
	set repoRoot = "C:\Git\fhir-profile-validation\"
	set namespace = "FHIRSERVER"                    // namespace to be created
	set appKey = "/fhir-validation"                 // web app path for the FHIR endpoint to be created
	set igList = repoRoot _ "profile"               // comma-separated list of directories or URLs containing FHIR profiles
	set javaGatewayHost = "localhost"               // Java Gateway host
	set javaGatewayPort = "55555"                   // Java Geteway port
	set terminologyServer = "https://tx.fhir.org/"  // FHIR Terminology Server
	set metadataPackageDirs = ""                    // this argument should only be used if you need to call $validate operation via HTTP GET and you are running on IRIS version prior to 2023.2
	if (+$System.Version.GetMajor() < 2023) || (($System.Version.GetMajor() = 2023) && (+$System.Version.GetMinor() < 2)) set metadataPackageDirs = repoRoot _ "src\search-params-package"
	set strategyClass = "isc.ateam.validation.FHIRValidationInteractionsStrategy"
	  
	zw ##class(App.Installer).setup(repoRoot, namespace, appKey, strategyClass, metadataPackageDirs, igList, javaGatewayHost, javaGatewayPort, terminologyServer)
	```
	Note that items within ```igList``` comma-separated list may be any valid values of ```-ig``` command-line argument described in [FHIR Validator documentation](https://confluence.hl7.org/pages/viewpage.action?pageId=35718580#UsingtheFHIRValidator-LoadinganimplementationGuide). For example, you can pass a URL pointing to a gzipped tarball that contains FHIR profiles.
	
	[setup()](../main/Installer.cls#L4) method creates the specified namespace and database, imports classes from [src/cls](../main/src/cls) directory, creates and configures FHIR endpoint based on the specified interactions strategy class, and imports some settings into the Configuration Registry of IRIS. The settings are used by [isc.ateam.validation.FHIRValidation](../main/src/cls/isc/ateam/validation/FHIRValidation.cls) class at runtime.

6. Download [FHIR Validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator#UsingtheFHIRValidator-Downloadingthevalidator) library from https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar to the ```jgw/lib``` subdirectory of the local repo dir.
7. Open IRIS Portal and browse to ```System Administration``` > ```Configuration``` > ```Connectivity``` > ```External Language Servers``` page. Modify the following settings of ```%Java Server``` gateway:
	| Setting             | Value                                 |
	| ------------------- | ------------------------------------- |
	| Port                | 55555                                 |
	| Class Path          | C:\Git\fhir-profile-validation\lib\\* |
	| Java Home Directory | <Full path to Java 11 JRE home>       |

## Testing with Postman
1. Import [fhir-profile-validation.postman_collection.json](../main/postman/fhir-profile-validation.postman_collection.json) file into Postman.
	* Adjust ```url``` variable defined in the collection.
2. Use the requests from the Postman collection to validate Patient and Bundle resources by calling ```$validate``` operation, or by POSTing resources to FHIR Repository. 
<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231098465-75b0fa7e-f866-4a84-be9d-02b27b75d73e.png" alt="Postman Collection" width="250"/></p>




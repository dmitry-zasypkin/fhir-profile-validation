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
1. Install [InterSystems IRIS for Health](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls) version 2022.1 or newer. The Community Edition is also acceptable.
2. Install Java 17 JRE.
3. Clone the repository into any local directory (```C:\Git\fhir-profile-validation``` in the following example):
	```
	C:\Git> git clone https://github.com/dmitry-zasypkin/fhir-profile-validation.git
	```
4. In IRIS terminal import [App.Installer](../main/Installer.cls) class into ```USER``` namespace:
	```
	USER> do $System.OBJ.Load("C:\Git\fhir-profile-validation\Installer.cls", "ck")
	```
5. Run [setup()](../main/Installer.cls#L4) method of ```App.Installer``` class passing it a number of parameters:
	```
	set repoRoot = "C:\Git\fhir-profile-validation\"
	set namespace = "FHIRSERVER"                    // namespace to be created
	set appKey = "/fhir-validation"                 // web app path for the FHIR endpoint to be created
	set igList = repoRoot _ "profile"               // comma-separated list of directories containing FHIR profiles
	set javaGatewayHost = "localhost"               // Java Gateway host
	set javaGatewayPort = "55555"                   // Java Geteway port
	set javaGatewayName = "%Java Server"            // Java Geteway name
	set terminologyServer = "https://tx.fhir.org/"  // FHIR Terminology Server
	set fhirVersion = "4.0"                         // FHIR version
	set fhirCorePackage = "hl7.fhir.r4.core@4.0.1"  // FHIR core package
	set metadataPackageDirs = ""                    // this argument should only be used if you need to call $validate operation via HTTP GET and you are running on IRIS version prior to 2023.2
	if (+$System.Version.GetMajor() < 2023) || (($System.Version.GetMajor() = 2023) && (+$System.Version.GetMinor() < 2)) set metadataPackageDirs = repoRoot _ "src\search-params-package"
	set strategyClass = "isc.ateam.validation.FHIRValidationInteractionsStrategy"
	  
	zw ##class(App.Installer).setup(repoRoot, namespace, appKey, strategyClass, metadataPackageDirs, igList, javaGatewayHost, javaGatewayPort, javaGatewayName, terminologyServer, fhirVersion, fhirCorePackage)
	```
	Note that items within ```igList``` comma-separated list may be any valid values of ```-ig``` command-line argument described in [FHIR Validator documentation](https://confluence.hl7.org/pages/viewpage.action?pageId=35718580#UsingtheFHIRValidator-LoadinganimplementationGuide). For example, you can pass a URL pointing to a gzipped tarball that contains FHIR profiles.
	
	[setup()](../main/Installer.cls#L4) method creates the specified namespace and database, imports classes from [src/cls](../main/src/cls) directory, creates and configures FHIR endpoint based on the specified interactions strategy class, and imports some settings into the [Configuration Registry](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/Doc.View.cls?KEY=HXREG_ch_configuration_registry) of IRIS. The settings are used by [isc.ateam.validation.FHIRValidation](../main/src/cls/isc/ateam/validation/FHIRValidation.cls) class at runtime.

	<p align="center"><img src="https://github.com/dmitry-zasypkin/fhir-profile-validation/assets/13035460/f123b34d-026e-4516-b430-ac5696d4111f" alt="Configuration Registry" width="500"/></p>

	If the ```tx.fhir.org``` terminology server turns out to be down during testing, you can replace it in the Configuration Registry with the address of another public FHIR terminology server by modifying the value of ```/FHIR/Validation/TerminologyServer``` setting. One commonly available server is ```https://r4.ontoserver.csiro.au/fhir/```.

6. Download [FHIR Validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator#UsingtheFHIRValidator-Downloadingthevalidator) library (version 6.6.3+) from https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar, and save it to the ```jgw/lib``` subdirectory of the repo directory.
7. Open IRIS Portal and browse to ```System Administration``` > ```Configuration``` > ```Connectivity``` > ```External Language Servers``` page. Modify the following settings of ```%Java Server``` gateway, or alternatively, create a new External Language Server of type ```Java``` with the appropriate settings. Start the gateway.
	| Setting             | Value                                     |
	| ------------------- | ----------------------------------------- |
	| Port                | 55555                                     |
	| Class Path          | C:\Git\fhir-profile-validation\jgw\lib\\* |
	| Java Home Directory | <Full path to Java 17 JRE home>           |

## Testing with Postman
1. Import [fhir-profile-validation.postman_collection.json](../main/postman/fhir-profile-validation.postman_collection.json) file into Postman.
	* Adjust ```url``` variable defined in the collection.
2. Use the requests from the Postman collection to validate Patient and Bundle resources by calling ```$validate``` operation, or by POSTing resources to FHIR Repository. 
<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231098465-75b0fa7e-f866-4a84-be9d-02b27b75d73e.png" alt="Postman Collection" width="250"/></p>




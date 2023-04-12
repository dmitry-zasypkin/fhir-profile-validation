# fhir-profile-validation
Validating FHIR resources against profiles in FHIR Resource Repository of [InterSystems IRIS for Health](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls) 2022+.

## Docker Installation
1. Clone the repo into any local directory, e.g.:
	```
	$ git clone https://github.com/dmitry-zasypkin/fhir-profile-validation.git
	$ cd fhir-profile-validation
	```
2. If necessary, put your FHIR profiles (as well as any related FHIR conformance and terminology resources) into ```profile``` directory which initially contains several sample profiles.
3. If necessary, edit [.env](../main/.env) file to use FHIR Terminology Server of your choice, or to change IRIS namespace or FHIR endpoint that will be created during installation.
	* Note that FHIR Terminology Server address can be modified at runtime in the [Configuration Registry](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/Doc.View.cls?KEY=HXREG_ch_configuration_registry) of IRIS.
4. If you intend to go through the [tutorial](#tutorial-fhir-validation-in-intersystems-iris-for-health), remove ```FHIR_ENDPOINT``` variable from [.env](../main/.env) file.
5. Build the images and start containers: 
	```
	$ docker-compose build
	$ docker-compose up -d
	```

## Testing with Postman
1. Import [fhir-profile-validation.postman_collection.json](../main/postman/fhir-profile-validation.postman_collection.json) file into Postman.
	* Adjust ```url``` variable defined in the collection.
2. Use the requests from the Postman collection to validate Patient and Bundle resources by calling ```$validate``` operation, or by POSTing resources to FHIR Repository. 
<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231098465-75b0fa7e-f866-4a84-be9d-02b27b75d73e.png" alt="Postman Collection" width="250"/></p>

# Tutorial: FHIR Validation in InterSystems IRIS for Health
This tutorial is intended to demonstrate approaches to creating FHIR profiles and validating FHIR resources against the profiles. By completing these exercises, you will learn how to:
* Create FHIR profiles with [FHIR Shorthand](http://hl7.org/fhir/uv/shorthand/).
* Configure FHIR Resource Repository of IRIS for Health to validate incoming FHIR resources against FHIR profiles.

## Initial Setup
1. For this tutorial you will need the following software installed locally:
	* [Docker](https://www.docker.com/products/docker-desktop/) and [Docker Compose](https://docs.docker.com/compose/install/)
	* [Visual Studio Code](https://code.visualstudio.com/download) with the following extensions:
		- [FHIR Shorthand](https://marketplace.visualstudio.com/items?itemName=MITRE-Health.vscode-language-fsh)
		- [InterSystems ObjectScript Extension Pack](https://marketplace.visualstudio.com/items?itemName=intersystems-community.objectscript-pack)
	* [Postman](https://www.postman.com/downloads/)
2. Clone the repo into any local directory, e.g.
	```
	git clone https://github.com/dmitry-zasypkin/fhir-profile-validation.git
	```
3. Remove ```FHIR_ENDPOINT``` variable from [.env](../main/.env) file. (We don't need a pre-created FHIR endpoint, as we will create one in the next exercises.)
4. Build and start [iris](../main/Dockerfile) and [jgw](../main/jgw/Dockerfile) containers by running ```docker-compose``` in the repo root directory, e.g.:
	```
	cd fhir-profile-validation
	docker-compose build
	docker-compose up -d
	```
5. Build [sushi](../main/sushi/Dockerfile) container with [SUSHI](https://fshschool.org/docs/sushi/) command-line compiler for [FHIR Shorthand](http://hl7.org/fhir/uv/shorthand/) files:
	```
	cd sushi
	docker-compose build
	```

## Visual Studio Code Configuration
6. Open VS Code and configure IRIS server connection:
	* Switch to [InterSystems Tools View](https://intersystems-community.github.io/vscode-objectscript/extensionui/#intersystems-tools-view) and click the [plus sign](https://intersystems-community.github.io/vscode-objectscript/configuration/#config-server) at the top of the pane to add a server. Enter the following server definition properties:
		* Name of new server definition: ```fhir-profile-validation```
		* Optional description: leave it blank
		* Hostname or IP address of web server: ```localhost```
		* Port of web server: ```32783```
		* Username: ```SuperUser```
		* Confirm connection type: ```http```
		* Password: ```SYS```
	* In the popup menu for the newly created server definition select ```Edit Settings```:
		<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231474028-9edab515-73f1-48f9-a75b-0f5accd3f44a.png" alt="Edit Settings menu" width="300"/></p>
	* Select ```never``` in the ```Delete Password On Signout``` dropdown. Click ```Edit in settings.json``` link to open settings.json file.
		<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231481171-796fe5be-4882-4b8c-a466-e00a9e24aba0.png" alt="Settings" width="450"/></p>
	* In ```objectscript.export``` object replace the value of [addCategory](https://intersystems-community.github.io/vscode-objectscript/settings/#:~:text=%22objectscript.export.addCategory%22) element with *true* in order to use ```src```/```cls``` folder for ObjectScript classes instead of just ```src```, then save and close the file.
		<p align="left"><img src="https://user-images.githubusercontent.com/13035460/231482541-560900d5-93be-40a0-94ec-e87b8e0b2313.png" alt="settings.json" width="450"/></p>
7. Open ```fhir-profile-validation``` folder via ```File``` > ```Open Folder…``` menu in VS Code.
8. Connect the folder to IRIS server:
	* Switch to [ObjectScript View](https://intersystems-community.github.io/vscode-objectscript/extensionui/#objectscript-view).
	* Click ```Choose Server and Namespace``` button, select ```fhir-profile-validation``` server definition, enter password (SYS) and select ```FHIRSERVER``` namespace.

## Creating FHIR Profiles with FHIR Shorthand
9. 

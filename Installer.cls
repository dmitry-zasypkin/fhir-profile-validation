Class App.Installer [ Abstract ]
{

ClassMethod setup(
	repoRoot As %String,
	namespace As %String,
	appKey As %String,
	strategyClass As %String,
	metadataPackageDirs As %List,
	fhirValidationIGList As %String,
	fhirValidationJavaGatewayServer As %String,
	fhirValidationJavaGatewayPort As %String,
	fhirValidationTerminologyServer As %String) As %Status
{
	new $namespace

	// Install a Foundation namespace
	zn "HSLIB"
	kill vars
	//set vars("Production") = productionClass
	$$$QuitOnError(##class(HS.Util.Installer.Foundation).Install(namespace, .vars))
	
	// Change to the new ns
	zn namespace

	// Import sources
	$$$QuitOnError($System.OBJ.LoadDir(repoRoot _ "/src/cls", "ck", ,1))

	// Populate Config Registry
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/IGList', :fhirValidationIGList))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/JavaGatewayServer', :fhirValidationJavaGatewayServer))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/JavaGatewayPort', :fhirValidationJavaGatewayPort))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/TerminologyServer', :fhirValidationTerminologyServer))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/SkipIfNoProfile', null))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/DefaultProfile/Patient', null))

	// Import additional FHIR packages
	#dim packageList As %List = ""
	if (metadataPackageDirs '= "") set packageList = ##class(HS.FHIRMeta.Load.NpmLoader).importPackages(metadataPackageDirs)

	if (appKey '= "")
	{	
		// Install an instance of a FHIR Service into the current namespace
		do ##class(HS.FHIRServer.Installer).InstallInstance(appKey, strategyClass, $lb("hl7.fhir.r4.core@4.0.1") _ packageList,,, 0)  // 0 = do not create separate databases for the FHIR data

		// Configure FHIR Service instance to accept unauthenticated requests
		#dim strategy As HS.FHIRServer.API.InteractionsStrategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(appKey)
		set config = strategy.GetServiceConfigData()
		set config.DebugMode = 4
		do strategy.SaveServiceConfigData(config)
	}
	
	/*
	// Load some FHIR data from either "fhirdata" or "data/fhir" directories
	#dim dataDir As %String = repoRoot _ "/fhirdata/"
	if '##class(%File).DirectoryExists(dataDir) set dataDir = repoRoot _ "/data/fhir/"
	$$$QuitOnError(##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles(dataDir, "FHIRServer", appKey))
	*/

	quit $$$OK
}

}

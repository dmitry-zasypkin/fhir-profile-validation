Class App.Installer [ Abstract ]
{

ClassMethod setup(
	repoRoot As %String,
	namespace As %String,
	appKey As %String,
	strategyClass As %String,
	metadataPackages As %List,
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

	// Install elements that are required for a FHIR-enabled namespace
	do ##class(HS.FHIRServer.Installer).InstallNamespace()

	// Import sources
	$$$QuitOnError($System.OBJ.LoadDir(repoRoot _ "/src/cls", "ck", ,1))

	// Populate Config Registry
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/IGList', :fhirValidationIGList))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/JavaGatewayServer', :fhirValidationJavaGatewayServer))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/JavaGatewayPort', :fhirValidationJavaGatewayPort))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/TerminologyServer', :fhirValidationTerminologyServer))
	&sql(INSERT INTO HS_Registry.Config(RegKey, RegValue) VALUES ('/FHIR/Validation/SkipIfNoProfile', '1'))
		
	// Install an instance of a FHIR Service into the current namespace
	do ##class(HS.FHIRServer.Installer).InstallInstance(appKey, strategyClass, metadataPackages,,, 0)  // 0 = do not create separate databases for the FHIR data

	// Configure FHIR Service instance to accept unauthenticated requests
	#dim strategy As HS.FHIRServer.API.InteractionsStrategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(appKey)
	set config = strategy.GetServiceConfigData()
	set config.DebugMode = 4
	do strategy.SaveServiceConfigData(config)
	
	/*
	// Load some FHIR data from either "fhirdata" or "data/fhir" directories
	#dim dataDir As %String = repoRoot _ "/fhirdata/"
	if '##class(%File).DirectoryExists(dataDir) set dataDir = repoRoot _ "/data/fhir/"
	$$$QuitOnError(##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles(dataDir, "FHIRServer", appKey))
	*/
	
	/* Uncomment the following code if using Durable %SYS
	
	// Mark program code database read-only in order to keep it inside the container
	zn "%SYS"
	set dbDir = $piece(##class(Config.Databases).DatabaseByName(namespace _ "CODE"), "^", *)
	write "Code database dir: " _ dbDir,!

	set db = ##class(SYS.Database).%OpenId(dbDir,, .sc)
	$$$QuitOnError(sc)
	set db.ReadOnly = 1
	set db.ResourceName = "%DB_"_$ZCVT(namespace,"U")
	$$$QuitOnError(db.%Save())
	*/

	quit $$$OK
}

}

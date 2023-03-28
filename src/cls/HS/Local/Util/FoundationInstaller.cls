Class HS.Local.Util.FoundationInstaller Extends HS.Util.Installer.Foundation
{

/// Overridden in order to set up a separate database for program code.
/// Name of the code database is expected in pVars("CodeDBName").
/// If not specified then we do not set up a separate db for code.
/// 
/// Method has been copied from HS.Util.Installer.ConfigItem (2022.1).
/// Modifications are marked with "//dz".
ClassMethod BuildDBNS(
	pNamespace,
	ByRef pVars,
	ByRef pLogFile,
	pDoMirror As %Boolean = 1,
	pSkipActivationLogging As %Boolean = 0) As %Status [ Internal ]
{
	#dim codeDBName As %String = $get(pVars("CodeDBName"))  //dz
	
	try {
		//dz: replaced this macro with logTextMacro() method call in order to be compatible to I4H 2021
		//#define LogText(%text) If (pSkipActivationLogging) { Write !, %text } Else { $$$ActivationLogInfo(pNamespace,%text) }
		
		new $namespace
		Set tSC = $$$OK
		Set $namespace="%SYS"
	 	// Check if pNamespace already exists
		Set tExists=##Class(Config.Namespaces).Exists(pNamespace)
		Set $namespace="HSLIB"
		Quit:tExists
		Set tDBName = $TR(pNamespace,"%-_","pdu")
		set DBResource="%DB_"_$ZCVT(tDBName,"U")

		If $Data(pVars("DBInstallDirectory"),tValue)#2 && (tValue '= "") {
			Set tDataDir = ##class(%File).NormalizeDirectory(tValue)
		}

		// Create the IRIS.DAT (if not already there)
		If $G(pVars("FromEnableEnsemble"))'=1 {
			//This gets set by %ZHSLIB.HealthShareMgr - the DB already exists, and might be mixed case
			do ..logTextMacro("About to Create Database "_tDBName, pNamespace, .pLogFile, pSkipActivationLogging) //dz: replaced $$$LogText macro with method call in order to be compatible to I4H 2021
			If $system.Mirror.IsMember() {
				do ..logTextMacro("Database Create must wait for all mirror members", pNamespace, .pLogFile, pSkipActivationLogging) //dz: replaced $$$LogText macro with method call in order to be compatible to I4H 2021
			}
			Set tSC=##class(HS.Util.SystemAPI).CreateDatabase(tDBName, pDoMirror, .tDataDir)
			Quit:$$$ISERR(tSC)
			do ..logTextMacro("Create "_$$$DatabaseFilename_" in "_tDataDir_tDBName, pNamespace, .pLogFile, pSkipActivationLogging) //dz: replaced $$$LogText macro with method call in order to be compatible to I4H 2021
			
			//dz
			if (codeDBName '= "")
			{
				do ..logTextMacro("About to Create Database "_codeDBName, pNamespace, .pLogFile, pSkipActivationLogging) //dz: replaced $$$LogText macro with method call in order to be compatible to I4H 2021
				Set tSC=##class(HS.Util.SystemAPI).CreateDatabase(codeDBName, pDoMirror, .tDataDir)
				Quit:$$$ISERR(tSC)
				do ..logTextMacro("Create "_$$$DatabaseFilename_" in "_tDataDir_codeDBName, pNamespace, .pLogFile, pSkipActivationLogging) //dz: replaced $$$LogText macro with method call in order to be compatible to I4H 2021
			}
		}

		// Create the Namespace (if not already there)
		//dz
		//Set tSC=##class(HS.Util.SystemAPI).Invoke("CreateNamespace",tDBName,pNamespace,tDBName,tDBName)
		Set tSC=##class(HS.Util.SystemAPI).Invoke("CreateNamespace",tDBName,pNamespace,$case(codeDBName, "":tDBName, :codeDBName),tDBName)
		Quit:$$$ISERR(tSC)
		do ..logTextMacro("Made Namespace "_pNamespace, pNamespace, .pLogFile, pSkipActivationLogging) //dz: replaced $$$LogText macro with method call in order to be compatible to I4H 2021
	} catch ex {
		Set tSC = ex.AsStatus()
	} 
	Quit tSC
}

/// This method is used instead of $$$LogText macro defined within 2022 version of BuildDBNS() method -- just to be compatible to I4H 2021
ClassMethod logTextMacro(
	text As %String,
	pNamespace As %String,
	ByRef pLogFile,
	pSkipActivationLogging As %Boolean = {$$$NO}) [ Private ]
{
	if (pSkipActivationLogging)
	{
		write !, text
		quit
	}
	
	if (+$System.Version.GetMajor() >= 2022) 
	{
		do ##class(HS.HC.Util.Installer).Log(.pLogFile, $$$CurrentClass, $$$CurrentMethod, text, pNamespace, 0)
	}
	else
	{
		do ##class(HS.HC.Util.Installer).Log(.pLogFile, $$$CurrentClass, $$$CurrentMethod, text)
	}
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}

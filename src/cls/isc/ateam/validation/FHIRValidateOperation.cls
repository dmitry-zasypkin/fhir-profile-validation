Class isc.ateam.validation.FHIRValidateOperation Extends HS.FHIRServer.Storage.BuiltIn.Validate
{

ClassMethod FHIRInstanceOpValidate(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, ByRef pResponse As HS.FHIRServer.API.Data.Response)
{
	#dim profile As %String = ""
	
	// try to extract profile from Parameters resource in request body
	#dim payload As %DynamicObject = pRequest.Json
	if (payload '= "") && (payload.resourceType = "Parameters")
	{
		#dim iter As %Iterator.Object = payload.parameter.%GetIterator()
		#dim entry As %DynamicObject
		#dim subsc As %Integer
		while iter.%GetNext(.subsc, .entry)
		{
			if (entry.name = "profile")
			{
				set profile = entry.valueCanonical
				
				// remove 'profile' parameter to avoid exception
				do payload.parameter.%Remove(subsc)
				quit
			}
		} // while
	}
	
	// then check URL parameters for 'profile'
	if (profile = "")
	{
		kill params
		do pRequest.Parameters.GetParameters("profile", .params)
		for i = params:-1:1
		{
			if (params(i).modifier '= "") $$$ThrowFHIR($$$GeneralError, "Modifiers are not supported for 'profile' parameter", "|400|error|invalid")
			set profile = profile _ $select(profile="":"", 1:",") _ $zstrip(params(i).value, "<>W", $c(13,10))
			
			// remove 'profile' parameter to avoid exception
			do pRequest.Parameters.RemoveParameter(params(i))
		}
	}
	
	// pass the context to the resource validator via process-scope global variables
	set %isFHIRValidateOperation = $$$YES
	set %FHIRValidateOperationProfileParam = profile  // can be empty
	
	#dim sc As %Status = $$$OK
	try
	{
		// call superclass method
		do ##super(pService, pRequest, .pResponse)
	}
	catch ex
	{
		set sc = ex.AsStatus()
	}
	
	kill %isFHIRValidateOperation
	kill %FHIRValidateOperationProfileParam
	
	$$$ThrowOnError(sc)
}

}


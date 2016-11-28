Function Get-ParameterSetInUse {
# get parameter set name to be used, based on parameters hash passed  
    [cmdletbinding()]
    param(
        # Supply the script info object, output of Get-Command -Name <DeploymentScript>.ps1
        [System.Management.Automation.ExternalScriptInfo]$ScriptInfo,
        
        # hashtable of all the parameters to be passed to the DeploymentScript
        [hashtable]$ParameterHash
    )

    $Metadata = [System.Management.Automation.CommandMetadata]::New($ScriptInfo)
    $CmdletBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($Metadata)
    $Parameters = [System.Management.Automation.ProxyCommand]::GetParamBlock($Metadata)

    $FunctionBody = @"
    $CmdletBinding
    param(
        $Parameters
    )
    return `$PSCmdlet.ParameterSetName    
"@

    $DummyFunction = [scriptblock]::Create($FunctionBody)

    & $DummyFunction @ParameterHash
}
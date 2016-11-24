<#
    .SYNOPSIS
        Uses ScheduledTasks PowerShell module to deploy scheduled tasks to Computers (available from Server 2012 onwards)
    .DESCRIPTION
    
        
    .PARAMETER Deployment
        Deployment to run
    
    .NOTES
   
        
#>
[CmdletBinding()]
param(
    [ValidateScript({ $_.PSObject.TypeNames[0] -eq 'PSDeploy.Deployment' })]
    [psobject[]]$Deployment,

    # Specify the Computer name. Default localhost.
    [String]$ComputerName = $env:ComputerName,

    # Specify the credentials used to connect to the computer, used to open a CIMSession
    [pscredential]$Credential,
    
    # Mention the name of the task.
    [String]$TaskName,

    # Specify an array of task actions, max of 32.
    [ValidateScript({$PSitem.Count -le 32})]
    [String[]]$TaskAction,

    # Specify the User id of the principal under whose context the scheduled task will run.
    [Parameter(ParameterSetName='TaskPrincipal')]
    [String]$RunAsUser,

    # Specifies the level of user rights that Task Scheduler uses to run the tasks that are associated with the principal
    [Parameter(ParameterSetName='TaskPrincipal')]
    [ValidateSet('Highest','LUA')]
    [String]$RunLevel,

    # Specifies the security logon method that Task Scheduler uses to run the tasks that are associated with the principal
    [Parameter(ParameterSetName='TaskPrincipal')]
    [ValidateSet('None','Password','S4U','Interactive','Group','ServiceAccount','Interactive or Password')]
    [String]$LogonType,

    [Parameter(ParameterSetName='TaskTriggerOnce')]
    [Switch]$Once,

    [Parameter(ParameterSetName='TaskTriggerOnce')]
    [Alias('StartTime')]
    [DateTime]$At,

    [Parameter(ParameterSetName='TaskTriggerOnce')]
    [Switch]$RandomDelay


)

foreach($Deploy in $Deployment)
{
    Do-SomethingWith $Deploy.DeploymentName
    Do-SomethingElseWith $Deploy.Source
    foreach($Target in $Deploy.Targets)
    {
        Deliver-SomethingTo $Target -From $Deploy.Source
    }
}
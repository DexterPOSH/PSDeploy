<#
    .SYNOPSIS
        Uses ScheduledTasks PowerShell module to deploy scheduled tasks to Computers (available from Server 2012 onwards)
    .DESCRIPTION
    
        
    .PARAMETER Deployment
        Deployment to run
    
    .NOTES
   
        
#>
#>
[CmdletBinding(DefaultParameterSetName='TaskTriggerOnce')]
param(
    [ValidateScript({ $_.PSObject.TypeNames[0] -eq 'PSDeploy.Deployment' })]
    [psobject[]]$Deployment,

    # Specify the Computer name 
    [String]$ComputerName,

    # Specify the credentials used to connect to the computer, used to open a CIMSession
    [pscredential]$Credential,
    
    # Mention the name of the task.
    [String]$TaskName,

    # Specify an array of task actions, max of 32.
    [ValidateScript({$PSitem.Count -le 32})]
    [String[]]$TaskAction,

    # Specify the User id of the principal under whose context the scheduled task will run.
    [Parameter(ParameterSetName='TaskWithPrincipalOnce')]
    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskWithPrincipalStartup')]
    [Parameter(ParameterSetName='TaskWithPrincipallogon')]
    [String]$RunAsUser,

    # Specifies the level of user rights that Task Scheduler uses to run the tasks that are associated with the principal
    [Parameter(ParameterSetName='TaskWithPrincipalOnce')]
    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskWithPrincipalStartup')]
    [Parameter(ParameterSetName='TaskWithPrincipallogon')]
    [ValidateSet('Highest','LUA')]
    [String]$RunLevel,

    # Specifies the security logon method that Task Scheduler uses to run the tasks that are associated with the principal
    [Parameter(ParameterSetName='TaskWithPrincipalOnce')]
    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskWithPrincipalStartup')]
    [Parameter(ParameterSetName='TaskWithPrincipallogon')]
    [ValidateSet('None','Password','S4U','Interactive','Group','ServiceAccount','Interactive or Password')]
    [String]$LogonType,

    [Parameter(ParameterSetName='TaskWithPrincipalOnce')]
    [Parameter(ParameterSetName='TaskTriggerOnce')]
    [Switch]$Once,

    [Parameter(ParameterSetName='TaskWithPrincipalOnce')]
    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskTriggerOnce')]
    [Parameter(ParameterSetName='TaskTriggerDaily')]
    [Parameter(ParameterSetName='TaskTriggerWeekly')]
    [Alias('StartTime')]
    [DateTime]$At,

    [Parameter(ParameterSetName='TaskWithPrincipal')]
    [Parameter(ParameterSetName='TaskTriggerOnce')]
    [Parameter(ParameterSetName='TaskTriggerDaily')]
    [Parameter(ParameterSetName='TaskTriggerWeekly')]
    [Parameter(ParameterSetName='TaskTriggerStartUp')]
    [Parameter(ParameterSetName='TaskTriggerLogon')]
    [Parameter(ParameterSetName='TaskWithPrincipalOnce')]
    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskWithPrincipalStartup')]
    [Parameter(ParameterSetName='TaskWithPrincipallogon')]
    [Switch]$RandomDelay,

    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskTriggerDaily')]
    [Switch]$Daily,

    [Parameter(ParameterSetName='TaskWithPrincipalDaily')]
    [Parameter(ParameterSetName='TaskTriggerDaily')]
    [int]$DaysInterval,

    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskTriggerWeekly')]
    [Switch]$Weekly,

    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskTriggerWeekly')]
    [string[]]$DaysOfWeek,

    [Parameter(ParameterSetName='TaskWithPrincipalWeekly')]
    [Parameter(ParameterSetName='TaskTriggerWeekly')]
    [int]$WeeksInInterval,

    [Parameter(ParameterSetName='TaskWithPrincipalStartup')]
    [Parameter(ParameterSetName='TaskTriggerStartUp')]
    [Switch]$AtStartUp,

    [Parameter(ParameterSetName='TaskWithPrincipallogon')]
    [Parameter(ParameterSetName='TaskTriggerLogon')]
    [Switch]$AtLogon

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
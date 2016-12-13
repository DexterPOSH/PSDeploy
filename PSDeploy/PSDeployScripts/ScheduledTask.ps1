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
    [String]$LogonType='None',

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
    [System.DayOfWeek[]]$DaysOfWeek,

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
[void]$PSBoundParameters.Remove('Deployment')
if (Get-Module -Name ScheduledTasks -ListAvailable) 
{
    Write-Verbose -message 'ScheduledTasks PowerShell module found.'
}
else 
{
    # TO DO add support usig schtasks.exe for backwards compatibility
    throw "ScheduledTasks PowerShell module NOT found. Deployment will exit. Requires Windows Server 2012 or Windows 8 and above on $env:COMPUTERNAME "
}

# Remove the above parameters from the PSBoundParameters
[Void]$PSBoundParameters.Remove('Credential')
[Void]$PSBoundParameters.Remove('ComputerName')
[Void]$PSBoundParameters.Remove('Deployment')
[Void]$PSBoundParameters.Remove('TaskAction')
[Void]$PSBoundParameters.Remove('TaskName')

foreach($Deploy in $Deployment)
{
    try 
    {
        # open a new CIM session
        $CIMSession = New-CIMSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
        $SchedTaskParamHash = @{
            CimSession = $CIMSession
        }

        # Create Task Princial (if required)
        if ($PSCmdlet.ParameterSetName -like "TaskWithPrincipal*") {
            # Create the task Princial
            $TaskPrincipal = New-ScheduledTaskPrincipal  -UserID $RunAsUser -RunLevel $RunLevel -LogonType $LogonType -ErrorAction Stop
            $SchedTaskParamHash.Add('Prinicipal',$TaskPrincipal)
        }

        # Create Task Trigger
        $TaskTrigger = New-ScheduledTaskTrigger @PSBoundParameters -CimSession $CIMSession -ErrorAction Stop
        $SchedTaskParamHash.Add('Trigger',$TaskTrigger)

        # Create Task actions
        # split the TaskAction passed on a whitespace, if there are arguments passed then use them
        $Executable, $Argument = $TaskAction -split ' ',2
        if (-not [String]::IsNullOrEmpty($Argument)) 
        {
            $TaskAction = New-ScheduledTaskAction -Execute $Executable -Argument $Argument -CimSession $CIMSession -ErrorAction Stop
        }
        else
        {
            $TaskAction = New-ScheduledTaskAction -Execute $Executable -CimSession $CIMSession -ErrorAction Stop
        }
        $SchedTaskParamHash.Add('Action', $TaskAction)

        # Create the Scheduled task
        $SchedTask = New-ScheduledTask @SchedTaskParamHash -ErrorAction Stop

        # Register the Scheduled task on the remote node
        Register-ScheduledTask -InputObject $SchedTask -TaskName $TaskName -ErrorAction Stop 
    }
    catch
    {
        Write-Warning -Message "[ScheduledTask] deployment failed for deployment ->  $($Deploy | Out-String)"
        #$PSCmdlet.ThrowTerminatingError($PSItem)
    }

}
function Set-RepeatingScheduledTask {
    <#
    .SYNOPSIS
    Creates or ReCreates a Scheduled Task which executes a pwsh script as interval.
    .COMPONENT
    ScriptProcessing
    .EXAMPLE
    Set-RepeatingScheduledTask -ScriptFile (Get-Item '.\test.ps1') -User "$env:COMPUTERNAME\page" -Password (Get-Secret 'localWS' 'page')
    .EXAMPLE
    $params = @{
        ScriptFile = Get-Item '.\test.ps1'
        ScriptParam = '-ALL'
        User = "$env:COMPUTERNAME\page"
        Password = Get-Secret 'localWS' 'page'
        TaskName = 'test script'
        TaskPath = "\page\"
        RepetitionInterval = (New-TimeSpan -Hours 12)
    }
    
    Set-RepeatingScheduledTask @params
    
    .NOTES
    The user needs following right: 
    Administrative Tools -> Local Security Policy -> Local Policies -> User Rights Assignment -> Log on as a batch job
    …but admin priviledges are also sufficient…
    #>
    [CmdletBinding()]
    param (
        # FileSystemInfo of the Scriptfile which should be executed
        [Parameter(mandatory=$true)][System.IO.FileSystemInfo]$ScriptFile,
        
        # Parameters to be passed to the script
        [string]$ScriptParam,
        
        # Specifies the user ID that Task Scheduler uses to run the tasks that are associated with the principal.
        [Parameter(mandatory=$true)][string]$User,
        
        # Password of User as SecureString
        [Parameter(mandatory=$true)][System.Security.SecureString]$Password,
        
        # Specifies the name of a scheduled task.
        [string]$TaskName,
        
        # Specifies an array of one or more paths for scheduled tasks in Task Scheduler namespace. You can use "*" for a wildcard character query. You can use \* for the root folder. To specify a full TaskPath you need to include the leading and trailing \. If you do not specify a path, the cmdlet uses the root folder.
        [string]$TaskPath = '\',
        
        # Specifies an amount of time between each restart of the task. The task will run, wait for the time interval specified, and then run again. 
        # Default: 1h
        [TimeSpan]$RepetitionInterval = (New-TimeSpan -Hours 1)
    )
    begin {
        if(!$TaskPath.StartsWith('\')) { $TaskPath = "\$TaskPath" }
        if(!$TaskPath.EndsWith('\')) { $TaskPath += "\" }
        if(!$TaskName) { $TaskName = $ScriptFile.BaseName }
    }
    process {

        Get-ScheduledTask -TaskName "$($ScriptFile.BaseName)" -TaskPath $TaskPath -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$false

        $act = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-NonInteractive -NoLogo -NoProfile -File $($ScriptFile.Name) $ScriptParam" -WorkingDirectory $ScriptFile.Directory
        $trg = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $RepetitionInterval
        $pcp = New-ScheduledTaskPrincipal -UserId $User -LogonType InteractiveOrPassword
        $set = New-ScheduledTaskSettingsSet -RestartInterval (New-TimeSpan -Minutes 10) -RestartCount 3
        $set.ExecutionTimeLimit = [System.Xml.XmlConvert]::ToString((New-TimeSpan -Hours 24))  # "PT24H"
        $tsk = New-ScheduledTask -Action $act -Principal $pcp -Trigger $trg -Settings $set
        $tsk | Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -User $User -Password ($Password | ConvertFrom-SecureString -AsPlainText) 
    }
}







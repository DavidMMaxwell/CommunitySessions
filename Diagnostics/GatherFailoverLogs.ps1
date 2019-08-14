<#
.SYNOPSIS
    Cluster Log File Gathering Script. 
    David M Maxwell, PFE @ Microsoft. 
    david.maxwell@microsoft.com
    August 2019

.VERSIONINFO
    0.1 - Initial Version. 
    0.2 - Added some error handling. 
        - Added check for log directory via SQL instance query rather than requiring it as a parameter.

.DESCRIPTION
    Gathers the appropriate logs from both SQL and Windows to troubleshoot cluster failover or AG issues. 
    Gathers the following: 
        * Windows Error Logs
        * Cluster Logs
        * SQL Error Logs
        * SQL System_Health XE Session
        * SQL AlwaysOn_Health XE Session

.NOTES
    Intented to be run locally on the computer in question. You can execute the script remotely via a 
    remote session, but the script must be copied locally to the server where it is intended to run. 

    Copy the script to C:\Temp on the server you wish to gather the logs on. You can then execute the 
    script (locally or remotely) by using the following: 

    ./GatherFailoverLogs.ps1 -SQLLogPath "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLServer\MSSQL\Log\"

    The only parameter required is the SQL Server log path, where the ERRORLOG and XE log files are. 
    
    Fully remote version of this is in the works... 

.EXAMPLE
    ./GatherFailoverLogs.ps1 -SQLLogPath "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLServer\MSSQL\Log\"

.PARAMETER $NodeName
    Provide the name of the computer you're connecting to / copying logs from. Otherwise this will run on the
    local computer. 

.PARAMETER $SQLInstance
    Provide the instance name you're gathering logs for. i.e.: 'DEV2016' For the default instance do not provide
    this parameter.

.PARAMETER $SkipSQLLogs
    Provide 'Y' to skip gathering the SQL Server error logs, AlwaysON_Health event logs and system_health event logs.

.PARAMETER $SkipClusterLogs
    Provide 'Y' to skip gathering the Windows Server Failover Cluster logs. 

#> 
Param([String]$NodeName = $env:COMPUTERNAME,
      [String]$SQLInstance = '',
      [String]$SkipSQLLogs = 'N',
      [String]$SkipClusterLogs = 'N'
      );

<# Check for admin rights. #>
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "This script requires administrative rights. Please re-run as Administrator."
    Break
}

<# Import modules if required. #>
Write-Host "Checking for required modules and loading if necessary." -ForegroundColor Green
if ($SkipSQLLogs -eq 'N'){
    if(!(Get-Module sqlserver)) {
        Write-Host "Loading SQLServer module..."
        try { Import-Module sqlserver -ErrorAction Stop}
        catch { Throw "Unable to import sqlserver module. Script cannot continue." }
    }
} else {
    Write-Host 'Skipping SQLServer logs and xevents.'
};

if ($SkipClusterLogs -eq 'N'){
    if(!(Get-Module FailoverClusters)) {
        Write-Host "Loading FailoverClusters module..."
        try { Import-Module FailoverClusters -ErrorAction Stop }
        catch { Throw "Unable to import FailoverClusters module. Script cannot continue." }    
    }
} else {
    Write-Host 'Skipping cluster logs.'
};

<# SQL version... #>
if ($SkipSQLLogs -eq 'N'){
    if ($SQLInstance -ne '') {$SQLInstance = $NodeName + '\' + $SQLInstance}
    $SQLLogPath = `
        (Invoke-Sqlcmd -ServerInstance $SQLInstance -Database master -Query `
        'select replace(cast(serverproperty(''ErrorLogFileName'') as varchar(256)),''ERRORLOG'','''')' `
        ).Column1;
    Write-Host "Gathering SQL logs from $SQLLogPath."
}

<# Create output directory #>
$FolderName = "ClusterLogs-$NodeName-$(get-date -Format yyyyMMddhhmmss)"
Write-Host "Creating output folder..." -ForegroundColor Green
try{$OutputFolder = New-Item -path "C:\temp\" -Name $FolderName -ItemType "directory"}
catch{Throw "Unable to create output folder. Script cannot continue. Check that the path is available and that you are running as administrator."}


<# BEGIN #>
<# Run each command for each set of files #>

<# Copy Windows Error Logs #>
Write-Host "Gathering System Event Logs" -ForegroundColor Green
if((Test-Path -Path "C:\Windows\System32\winevt\logs\System.evtx") -eq $True) {
    Copy-Item -Path "C:\Windows\System32\winevt\logs\System.evtx" -Destination $OutputFolder
    Copy-Item -Path "C:\Windows\System32\winevt\logs\Security.evtx" -Destination $OutputFolder
    Copy-Item -Path "C:\Windows\System32\winevt\logs\Application.evtx" -Destination $OutputFolder
} else {
    Write-Error "Unable to locate Windows event log files. Please check your Windows log path. Script will continue."
}

<# Gather Cluster Logs #>
if ($SkipClusterLogs -eq 'N'){
    Write-Host "Gathering Cluster Logs" -ForegroundColor Green
    try {Get-ClusterLog -Node $NodeName -Destination $OutputFolder -UseLocalTime}
    catch {Write-Error "Unable to get cluster logs. Check to ensure that this node is part of a cluster. Script will continue."}
};

<# Gather SQL Logs #>
if ($SkipSQLLogs -eq 'N'){
Write-Host "Gathering SQL Server Logs" -ForegroundColor Green
if((Test-Path -Path "$SQLLogPath\ERRORLOG") -eq $True) {
    Copy-Item -Path "$SQLLogPath\ERRORLOG*" -Destination $OutputFolder
    Copy-Item -Path "$SQLLogPath\system_health*.xel" -Destination $OutputFolder
    Copy-Item -Path "$SQLLogPath\AlwaysOn_health*.xel" -Destination $OutputFolder
} else {    
    Write-Error "Unable to locate SQL log files from $SQLLogPath. Script will continue." 
    }
}

<# Compress the output folder for posting. #>
Write-Host "Compressing output folder." -ForegroundColor Green
try{Compress-Archive -Path $OutputFolder -DestinationPath "$OutputFolder.zip"}
catch{Write-Host "Unable to create compressed folder. Exiting." -ForegroundColor Red}
<# END #>




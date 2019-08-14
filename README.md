# DemScriptsTho
This folder is for one-off scripts used for diagnostic purposes. Constructive feedback is encouraged. 

# Scripts 
** BackupHistory.sql **
Selects info from MSDB backup tables and shows full, log & diff backup history for all databases. Includes throughput info for troubleshooting IO speed.

** GatherFailoverLogs.ps1 **
Gathers the Windows Error Logs and optionally the following: 
* SQL Server Error Logs
* SQL AlwaysOn_Health XE session logs
* SQL System_Health XE session logs
* Cluster error logs
These logs can be reviewed or used with CSS's FailoverDetector tool for troubleshooting. 

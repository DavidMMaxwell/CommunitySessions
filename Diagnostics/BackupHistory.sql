DECLARE @dt datetime
SELECT @dt = dateadd(dd,-30,CURRENT_TIMESTAMP)

SELECT 
  bs.database_name AS DBName
 ,bs.recovery_model AS RecModel
 ,CASE bs.type 
    WHEN 'D' THEN 'Full'
    WHEN 'I' THEN 'Diff'
    WHEN 'L' THEN 'TLog'
    ELSE 'Unknown'
  END AS BackupType
 ,bs.backup_finish_date AS DateCompleted
 ,Duration = DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date)
 ,CAST(ROUND(bs.backup_size / 1048576.0,2) AS numeric(10,2)) AS DataSizeMB
 ,[MB/sec] = CAST(ROUND((bs.backup_size / 1048576.0) / 
      CASE 
        WHEN DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) > 0 
        THEN DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date)
        ELSE 1
      END,2) AS numeric(10,2))
 ,convert(decimal(4,1), ((bs.compressed_backup_size / bs.backup_size) * 100)) as CompressedPct
 ,bs.[user_name] AS UserName
 ,bmf.physical_device_name AS BackupFile
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediafamily AS bmf
  ON bs.media_set_id = bmf.media_set_id
WHERE bs.backup_finish_date > @dt
ORDER BY 
  bs.backup_finish_date DESC;
GO
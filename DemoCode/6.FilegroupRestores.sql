USE [master];
GO


/****************************************************************************************
--Take full backup
*****************************************************************************************/


BACKUP DATABASE [PartitioningDemo]
TO DISK = N'C:\SQLServer\SQLBackup\PartitioningDemo.BAK'
WITH INIT,COMPRESSION;
GO


/****************************************************************************************
--Check data
*****************************************************************************************/


USE [PartitioningDemo];
GO

SELECT 
	p.partition_number, p.partition_id, fg.name AS [filegroup],
	r.boundary_id, CONVERT(DATE,r.value) AS BoundaryValue, p.rows
FROM 
	sys.tables AS t
INNER JOIN
	sys.indexes AS i ON t.object_id = i.object_id
INNER JOIN
	sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id 
INNER JOIN 
    sys.allocation_units a ON a.container_id = p.hobt_id 
INNER JOIN 
    sys.filegroups fg ON fg.data_space_id = a.data_space_id 
INNER JOIN
	sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
INNER JOIN
	sys.partition_functions AS f ON s.function_id = f.function_id
LEFT OUTER JOIN 
	sys.partition_range_values AS r ON f.function_id = r.function_id 
									AND r.boundary_id = p.partition_number
WHERE 
	i.type <= 1 AND a.type = 1
AND 
	t.name = 'PartitionedTable'
ORDER BY 
	p.partition_number 
		DESC;
GO


/****************************************************************************************
--Take backups of all the filegroups
*****************************************************************************************/


USE [PartitioningDemo];
GO

EXEC sp_helpfile;
GO


USE [master];
GO

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'PRIMARY'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_PRIMARY.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA1'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA1.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA2'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA2.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA3'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA3.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA4'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA4.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA5'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA5.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA6'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA6.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA7'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA7.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA8'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA8.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA9'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA9.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA10'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA10.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA11'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA11.bak';

BACKUP DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA12'
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA12.bak';
GO


/****************************************************************************************
--Take transaction log backup
*****************************************************************************************/


BACKUP LOG [PartitioningDemo]
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_LogBackup.trn'
GO


/****************************************************************************************
--Check the data
*****************************************************************************************/


USE [PartitioningDemo];
GO

SELECT 
	p.partition_number, p.partition_id, fg.name AS [filegroup],
	r.boundary_id, CONVERT(DATE,r.value) AS BoundaryValue, p.rows
FROM 
	sys.tables AS t
INNER JOIN
	sys.indexes AS i ON t.object_id = i.object_id
INNER JOIN
	sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id 
INNER JOIN 
    sys.allocation_units a ON a.container_id = p.hobt_id 
INNER JOIN 
    sys.filegroups fg ON fg.data_space_id = a.data_space_id 
INNER JOIN
	sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
INNER JOIN
	sys.partition_functions AS f ON s.function_id = f.function_id
LEFT OUTER JOIN 
	sys.partition_range_values AS r ON f.function_id = r.function_id 
									AND r.boundary_id = p.partition_number
WHERE 
	i.type <= 1 AND a.type = 1
AND 
	t.name = 'PartitionedTable'
ORDER BY 
	p.partition_number 
		DESC;
GO


/****************************************************************************************
--Wipe some data
*****************************************************************************************/


TRUNCATE TABLE dbo.PartitionedTable WITH (PARTITIONS (6));
GO


/****************************************************************************************
--Check the data
*****************************************************************************************/


SELECT 
	p.partition_number, p.partition_id, fg.name AS [filegroup],
	r.boundary_id, CONVERT(DATE,r.value) AS BoundaryValue, p.rows
FROM 
	sys.tables AS t
INNER JOIN
	sys.indexes AS i ON t.object_id = i.object_id
INNER JOIN
	sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id 
INNER JOIN 
    sys.allocation_units a ON a.container_id = p.hobt_id 
INNER JOIN 
    sys.filegroups fg ON fg.data_space_id = a.data_space_id 
INNER JOIN
	sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
INNER JOIN
	sys.partition_functions AS f ON s.function_id = f.function_id
LEFT OUTER JOIN 
	sys.partition_range_values AS r ON f.function_id = r.function_id 
									AND r.boundary_id = p.partition_number
WHERE 
	i.type <= 1 AND a.type = 1
AND 
	t.name = 'PartitionedTable'
ORDER BY 
	p.partition_number 
		DESC;
GO


/****************************************************************************************
--Take tail-log backup
*****************************************************************************************/

USE [master];
GO

BACKUP LOG [PartitioningDemo]
TO DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_TailLogBackup.trn'
WITH NORECOVERY;
GO


/****************************************************************************************
--Restore primary and one filegroup backup
*****************************************************************************************/


RESTORE DATABASE [PartitioningDemo]
   FILEGROUP = 'PRIMARY'
   FROM DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_PRIMARY.bak'
   WITH PARTIAL,REPLACE,NORECOVERY;
GO


RESTORE DATABASE [PartitioningDemo]
   FILEGROUP = 'DATA9'
   FROM DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_DATA9.bak'
   WITH NORECOVERY;
GO


/****************************************************************************************
--Restore transaction log backup
*****************************************************************************************/


RESTORE LOG [PartitioningDemo]
FROM DISK = 'C:\SQLServer\SQLBackup\PartitioningDemo_LogBackup.trn'
WITH NORECOVERY;
GO


/****************************************************************************************
--Recover the database
*****************************************************************************************/


RESTORE DATABASE [PartitioningDemo] WITH RECOVERY;
GO


/****************************************************************************************
--Check the partitions
*****************************************************************************************/


USE [PartitioningDemo];
GO

SELECT 
	p.partition_number, p.partition_id, fg.name AS [filegroup],
	r.boundary_id, CONVERT(DATE,r.value) AS BoundaryValue, p.rows
FROM 
	sys.tables AS t
INNER JOIN
	sys.indexes AS i ON t.object_id = i.object_id
INNER JOIN
	sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id 
INNER JOIN 
    sys.allocation_units a ON a.container_id = p.hobt_id 
INNER JOIN 
    sys.filegroups fg ON fg.data_space_id = a.data_space_id 
INNER JOIN
	sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
INNER JOIN
	sys.partition_functions AS f ON s.function_id = f.function_id
LEFT OUTER JOIN 
	sys.partition_range_values AS r ON f.function_id = r.function_id 
									AND r.boundary_id = p.partition_number
WHERE 
	i.type <= 1 AND a.type = 1
AND 
	t.name = 'PartitionedTable'
ORDER BY 
	p.partition_number 
		DESC;
GO


/****************************************************************************************
--Try selecting the data in the table
*****************************************************************************************/


SELECT * FROM dbo.PartitionedTable
WHERE CreatedDate >= '2018-01-01' AND CreatedDate < '2019-01-01'
GO



SELECT * FROM dbo.PartitionedTable
WHERE CreatedDate >= '2017-01-01' AND CreatedDate < '2018-01-01'
GO
USE [master];
GO

/****************************************************************************************
--Create database
*****************************************************************************************/

DROP DATABASE IF EXISTS [PartitioningDemo];
GO

CREATE DATABASE [PartitioningDemo]
 ON PRIMARY 
	(NAME = N'PartitionDemo', FILENAME = N'C:\SQLServer\SQLData\PartitionDemo.mdf'), 
	 FILEGROUP [DATA1] 
	(NAME = N'DATA1', FILENAME = N'C:\SQLServer\SQLData\DATA1.ndf'),
	 FILEGROUP [DATA2] 
	(NAME = N'DATA2', FILENAME = N'C:\SQLServer\SQLData\DATA2.ndf'),
	 FILEGROUP [DATA3] 
	(NAME = N'DATA3', FILENAME = N'C:\SQLServer\SQLData\DATA3.ndf'),
	 FILEGROUP [DATA4] 
	(NAME = N'DATA4', FILENAME = N'C:\SQLServer\SQLData\DATA4.ndf'),
	 FILEGROUP [DATA5] 
	(NAME = N'DATA5', FILENAME = N'C:\SQLServer\SQLData\DATA5.ndf'),
	 FILEGROUP [DATA6] 
	(NAME = N'DATA6', FILENAME = N'C:\SQLServer\SQLData\DATA6.ndf'),
	 FILEGROUP [DATA7] 
	(NAME = N'DATA7', FILENAME = N'C:\SQLServer\SQLData\DATA7.ndf'),
	 FILEGROUP [DATA8] 
	(NAME = N'DATA8', FILENAME = N'C:\SQLServer\SQLData\DATA8.ndf'),
	 FILEGROUP [DATA9] 
	(NAME = N'DATA9', FILENAME = N'C:\SQLServer\SQLData\DATA9.ndf'),
	 FILEGROUP [DATA10] 
	(NAME = N'DATA10', FILENAME = N'C:\SQLServer\SQLData\DATA10.ndf'),
	 FILEGROUP [DATA11] 
	(NAME = N'DATA11', FILENAME = N'C:\SQLServer\SQLData\DATA11.ndf'),
	 FILEGROUP [DATA12] 
	(NAME = N'DATA12', FILENAME = N'C:\SQLServer\SQLData\DATA12.ndf')
 LOG ON 
	(NAME = N'PartitionDemo_log', FILENAME = N'C:\SQLServer\SQLLog\PartitionDemo_log.ldf')
GO


/****************************************************************************************
--Create partition function (LEFT) & scheme
*****************************************************************************************/


USE [PartitioningDemo];
GO


CREATE PARTITION FUNCTION PF_PartitionedTable(DATE)
	   AS RANGE LEFT 
    FOR VALUES ('2011-01-01','2012-01-01','2013-01-01',
                '2014-01-01','2015-01-01','2016-01-01',
                '2017-01-01');
GO


CREATE PARTITION SCHEME PS_PartitionedTable
    AS PARTITION PF_PartitionedTable
TO ([DATA1],[DATA2],[DATA3],[DATA4],[DATA5],[DATA6],[DATA7],[DATA8]);
GO


/****************************************************************************************
--Create partitioned table
*****************************************************************************************/


CREATE TABLE dbo.PartitionedTable
(ID INT IDENTITY(1,1),
 ColA VARCHAR(10),
 ColB VARCHAR(10),
 CreatedDate DATE)
 ON PS_PartitionedTable(CreatedDate);
GO


/****************************************************************************************
--Check partitions
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


/****************************************************************************************
--Check destination of data
*****************************************************************************************/


--https://docs.microsoft.com/en-us/sql/t-sql/functions/partition-transact-sql
SELECT $Partition.PF_PartitionedTable('2012-01-01') AS [2012-01-01 Destination Partition]
SELECT $Partition.PF_PartitionedTable('2011-12-31') AS [2011-12-31 Destination Partition]
SELECT $Partition.PF_PartitionedTable('2011-01-01') AS [2011-01-01 Destination Partition]
GO


/****************************************************************************************
--Drop everything and recreate
*****************************************************************************************/


USE [PartitioningDemo];
GO


DROP TABLE dbo.PartitionedTable;
DROP PARTITION SCHEME PS_PartitionedTable;
DROP PARTITION FUNCTION PF_PartitionedTable;
GO


CREATE PARTITION FUNCTION PF_PartitionedTable(DATE)
	   AS RANGE RIGHT 
    FOR VALUES ('2011-01-01','2012-01-01','2013-01-01',
                '2014-01-01','2015-01-01','2016-01-01',
                '2017-01-01');
GO


CREATE PARTITION SCHEME PS_PartitionedTable
    AS PARTITION PF_PartitionedTable
TO ([DATA1],[DATA2],[DATA3],[DATA4],[DATA5],[DATA6],[DATA7],[DATA8]);
GO


CREATE TABLE dbo.PartitionedTable
(ID INT IDENTITY(1,1),
 ColA VARCHAR(10),
 ColB VARCHAR(10),
 CreatedDate DATE)
 ON PS_PartitionedTable(CreatedDate);
GO


/****************************************************************************************
--Check destination of data
*****************************************************************************************/


--https://docs.microsoft.com/en-us/sql/t-sql/functions/partition-transact-sql
SELECT $Partition.PF_PartitionedTable('2012-01-01') AS [2012-01-01 Destination Partition]
SELECT $Partition.PF_PartitionedTable('2011-12-31') AS [2011-12-31 Destination Partition]
SELECT $Partition.PF_PartitionedTable('2011-01-01') AS [2011-01-01 Destination Partition]
GO


/****************************************************************************************
--Insert data
*****************************************************************************************/


--https://stackoverflow.com/questions/9645348/how-to-insert-1000-random-dates-between-a-given-range
SET NOCOUNT ON;
SET STATISTICS IO OFF;

DECLARE @FromDate date = '2012-01-01'
DECLARE @ToDate date = '2017-01-01'

INSERT INTO dbo.PartitionedTable
SELECT 
    REPLICATE('A',10),
    REPLICATE('B',10),
    DATEADD(DAY, RAND(CHECKSUM(NEWID()))*(1+DATEDIFF(DAY, @FromDate, @ToDate)), @FromDate);
GO 1000


/****************************************************************************************
--Check partitions
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




TRUNCATE TABLE dbo.PartitionedTable WITH (PARTITIONS (8));
GO

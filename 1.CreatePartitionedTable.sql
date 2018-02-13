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
--Create partition function & scheme
*****************************************************************************************/


USE [PartitioningDemo];
GO

DECLARE @CurrentDate DATE = GETDATE();

CREATE PARTITION FUNCTION PF_PartitionedTable(DATE)
	   AS RANGE RIGHT 
    FOR VALUES (DATEADD(dd,-4,@CurrentDate),DATEADD(dd,-3,@CurrentDate),
				DATEADD(dd,-2,@CurrentDate),DATEADD(dd,-1,@CurrentDate),
				@CurrentDate,
				DATEADD(dd,1,@CurrentDate),DATEADD(dd,2,@CurrentDate),
				DATEADD(dd,3,@CurrentDate),DATEADD(dd,4,@CurrentDate));
GO


CREATE PARTITION SCHEME PS_PartitionedTable
    AS PARTITION PF_PartitionedTable
TO ([DATA1],[DATA2],[DATA3],[DATA4],[DATA5],[DATA6],[DATA7],[DATA8],[DATA9],[DATA10]);
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
--Insert data
*****************************************************************************************/


SET NOCOUNT ON;
SET STATISTICS IO OFF;

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,-3,@CurrentDate));
GO 100

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,-2,@CurrentDate));
GO 100

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,-1,@CurrentDate));
GO 100

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),@CurrentDate);
GO 100

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,+1,@CurrentDate));
GO 100

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,+2,@CurrentDate));
GO 100

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,+3,@CurrentDate));
GO 50


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	p.partition_number, p.partition_id, fg.name AS [filegroup],
	r.boundary_id, r.value AS BoundaryValue, p.rows
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
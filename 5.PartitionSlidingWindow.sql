USE [PartitioningDemo];
GO


/****************************************************************************************
--Create archive table
*****************************************************************************************/


DROP TABLE IF EXISTS dbo.PartitionedTable_Archive

CREATE TABLE dbo.PartitionedTable_Archive
(ID INT IDENTITY(1,1),
 ColA VARCHAR(10),
 ColB VARCHAR(10),
 CreatedDate DATE)
 ON PS_PartitionedTable(CreatedDate);


CREATE UNIQUE CLUSTERED INDEX [IX_CreatedDate_PartitionedTable_Archive] ON dbo.PartitionedTable_Archive
 (CreatedDate,ID) 
ON PS_PartitionedTable(CreatedDate);
GO

CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable_Archive] ON dbo.PartitionedTable_Archive
 (ColA) 
ON PS_PartitionedTable(CreatedDate);
GO


/****************************************************************************************
--Create staging table
*****************************************************************************************/


DROP TABLE IF EXISTS dbo.PartitionedTable_Staging

CREATE TABLE dbo.PartitionedTable_Staging
(ID INT IDENTITY(1,1),
 ColA VARCHAR(10),
 ColB VARCHAR(10),
 CreatedDate DATE)
 ON PS_PartitionedTable(CreatedDate);


CREATE UNIQUE CLUSTERED INDEX [IX_CreatedDate_PartitionedTable_Staging] ON dbo.PartitionedTable_Staging
 (CreatedDate,ID) 
ON PS_PartitionedTable(CreatedDate);
GO

CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable_Staging] ON dbo.PartitionedTable_Staging
 (ColA) 
ON PS_PartitionedTable(CreatedDate);
GO


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	t.name, p.partition_number, p.partition_id, fg.name AS [filegroup],
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
	t.name IN ('PartitionedTable','PartitionedTable_Archive','PartitionedTable_Staging')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


/****************************************************************************************
--Switch oldest partition to archive table
*****************************************************************************************/


ALTER TABLE [dbo].PartitionedTable
	SWITCH PARTITION 1
TO [dbo].PartitionedTable_Archive
		PARTITION 1;
GO


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	t.name, p.partition_number, p.partition_id, fg.name AS [filegroup],
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
	t.name IN ('PartitionedTable','PartitionedTable_Archive')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


/****************************************************************************************
--Merge oldest partition in live table
*****************************************************************************************/


ALTER PARTITION FUNCTION PF_PartitionedTable()
MERGE RANGE ('VALUE');
GO


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	t.name, p.partition_number, p.partition_id, fg.name AS [filegroup],
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
	t.name IN ('PartitionedTable','PartitionedTable_Archive')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


/****************************************************************************************
--Split new partition
*****************************************************************************************/


ALTER DATABASE [PartitioningDemo] ADD FILEGROUP [DATA13]
GO
ALTER DATABASE [PartitioningDemo] ADD FILE ( NAME = N'DATA13', FILENAME = N'C:\SQLServer\SQLData\DATA13.ndf') TO FILEGROUP [DATA13]
GO


ALTER PARTITION SCHEME PS_PartitionedTable
NEXT USED [DATA13];

ALTER PARTITION FUNCTION PF_PartitionedTable()
SPLIT RANGE ('VALUE');
GO


/****************************************************************************************
--Load data into Staging table
*****************************************************************************************/

SET NOCOUNT ON;

DECLARE @CurrentDate DATE = GETDATE();
INSERT INTO dbo.PartitionedTable_Staging
(ColA,ColB,CreatedDate)
VALUES
(REPLICATE('A',10),REPLICATE('A',10),DATEADD(dd,+6,@CurrentDate));
GO 100


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	t.name, p.partition_number, p.partition_id, fg.name AS [filegroup],
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
	t.name IN ('PartitionedTable','PartitionedTable_Staging')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


/****************************************************************************************
--Switch new data from staging table to live table
*****************************************************************************************/


ALTER TABLE [dbo].PartitionedTable_Staging
	SWITCH PARTITION 9
TO [dbo].PartitionedTable
		PARTITION 9;
GO


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	t.name, p.partition_number, p.partition_id, fg.name AS [filegroup],
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
	t.name IN ('PartitionedTable','PartitionedTable_Staging')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO
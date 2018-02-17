USE [PartitioningDemo];
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
	t.name IN ('PartitionedTable')
ORDER BY 
	t.name, p.partition_number 
		DESC;
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
 ON [DATA1];


CREATE UNIQUE CLUSTERED INDEX [IX_CreatedDate_PartitionedTable_Archive] ON dbo.PartitionedTable_Archive
 (CreatedDate,ID) 
ON [DATA1];
GO

CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable_Archive] ON dbo.PartitionedTable_Archive
 (ColA) 
ON [DATA1];
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
 ON [DATA9];


CREATE UNIQUE CLUSTERED INDEX [IX_CreatedDate_PartitionedTable_Staging] ON dbo.PartitionedTable_Staging
 (CreatedDate,ID) 
 ON [DATA9];
GO

CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable_Staging] ON dbo.PartitionedTable_Staging
 (ColA) 
 ON [DATA9];
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
--Check partitions & archive table
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
	t.name IN ('PartitionedTable')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


SELECT COUNT(*) as [Row Count] FROM [dbo].PartitionedTable_Archive;
GO


/****************************************************************************************
--Merge oldest partition in live table
*****************************************************************************************/

SET STATISTICS IO ON;

ALTER PARTITION FUNCTION PF_PartitionedTable()
MERGE RANGE ('2013-01-01');
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
	t.name IN ('PartitionedTable')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


/****************************************************************************************
--Split new partition
*****************************************************************************************/


ALTER PARTITION SCHEME PS_PartitionedTable
NEXT USED [DATA11];

ALTER PARTITION FUNCTION PF_PartitionedTable()
SPLIT RANGE ('2020-01-01');
GO


/****************************************************************************************
--Load data into Staging table and add constraint
*****************************************************************************************/


--https://stackoverflow.com/questions/9645348/how-to-insert-1000-random-dates-between-a-given-range
SET NOCOUNT ON;
SET STATISTICS IO OFF;

DECLARE @FromDate DATE = '2018-01-01'
DECLARE @ToDate DATE = '2018-12-31'

INSERT INTO dbo.PartitionedTable_Staging
SELECT 
    REPLICATE('A',10),
    REPLICATE('B',10),
    DATEADD(DAY, RAND(CHECKSUM(NEWID()))*(1+DATEDIFF(DAY, @FromDate, @ToDate)), @FromDate);
GO 250



ALTER TABLE dbo.PartitionedTable_Staging
		ADD CONSTRAINT CreatedDate_Staging_CHECK CHECK 
			(CreatedDate >= CONVERT(DATE,'2018-01-01') AND CreatedDate < CONVERT(DATE,'2019-01-01')
            AND CreatedDate IS NOT NULL);
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
	t.name IN ('PartitionedTable','PartitionedTable_Staging')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


SELECT COUNT(*) as [Row Count] FROM [dbo].PartitionedTable_Staging;
GO


/****************************************************************************************
--Switch new data from staging table to live table
*****************************************************************************************/


ALTER TABLE [dbo].PartitionedTable_Staging
	SWITCH PARTITION 1
TO [dbo].PartitionedTable
		PARTITION 6;
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
	t.name IN ('PartitionedTable')
ORDER BY 
	t.name, p.partition_number 
		DESC;
GO


SELECT COUNT(*) as [Row Count] FROM [dbo].PartitionedTable_Staging;
GO
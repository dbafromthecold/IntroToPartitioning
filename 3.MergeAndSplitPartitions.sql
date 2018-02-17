USE [PartitioningDemo];
GO


/****************************************************************************************
--Check Partitions
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
GO


/****************************************************************************************
--Merge oldest partition
*****************************************************************************************/


SET STATISTICS IO ON;

ALTER PARTITION FUNCTION PF_PartitionedTable()
MERGE RANGE ('2011-01-01');
GO


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
GO


/****************************************************************************************
--Merge oldest partition again
*****************************************************************************************/


SET STATISTICS IO ON;

ALTER PARTITION FUNCTION PF_PartitionedTable()
MERGE RANGE ('2012-01-01');
GO


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
GO


/****************************************************************************************
--Split newest partition
*****************************************************************************************/


SET STATISTICS IO ON;

ALTER PARTITION SCHEME PS_PartitionedTable
NEXT USED [DATA9];

ALTER PARTITION FUNCTION PF_PartitionedTable()
SPLIT RANGE ('2018-01-01');
GO


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
GO


/****************************************************************************************
--Fire in some more data
*****************************************************************************************/


--https://stackoverflow.com/questions/9645348/how-to-insert-1000-random-dates-between-a-given-range
SET NOCOUNT ON;
SET STATISTICS IO OFF;

DECLARE @FromDate date = '2017-01-01'
DECLARE @ToDate date = '2020-01-01'

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
GO


/****************************************************************************************
--Split newest partition
*****************************************************************************************/


SET STATISTICS IO ON;

ALTER PARTITION SCHEME PS_PartitionedTable
NEXT USED [DATA10];

ALTER PARTITION FUNCTION PF_PartitionedTable()
SPLIT RANGE ('2019-01-01');
GO


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
GO



/****************************************************************************************
--Truncate partition
*****************************************************************************************/


TRUNCATE TABLE dbo.PartitionedTable WITH (PARTITIONS (7));
GO


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
GO


/****************************************************************************************
--Truncate open partition
*****************************************************************************************/


TRUNCATE TABLE dbo.PartitionedTable WITH (PARTITIONS (8));
GO

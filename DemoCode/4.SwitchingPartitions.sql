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
	t.name = 'PartitionedTable'
ORDER BY 
	p.partition_number 
		DESC;
GO


/****************************************************************************************
--Create switch table
*****************************************************************************************/


DROP TABLE IF EXISTS dbo.PartitionedTable_Switch

CREATE TABLE dbo.PartitionedTable_Switch
(ID INT IDENTITY(1,1),
 ColA VARCHAR(10),
 ColB VARCHAR(10),
 CreatedDate DATE)
 ON [DATA1];


CREATE UNIQUE CLUSTERED INDEX [IX_CreatedDate_PartitionedTable_Switch] ON dbo.PartitionedTable_Switch
 (CreatedDate,ID) 
ON [DATA1];
GO

CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable_Switch] ON dbo.PartitionedTable_Switch
 (ColA) 
ON [DATA1];
GO


/****************************************************************************************
--Switch partitions
*****************************************************************************************/

SET STATISTICS IO ON;

ALTER TABLE [dbo].PartitionedTable
	SWITCH PARTITION 1
TO [dbo].PartitionedTable_Switch;
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
GO


/****************************************************************************************
--Check data in switch table
*****************************************************************************************/


SELECT COUNT(*) AS [RowCount] FROM dbo.PartitionedTable_Switch;
GO


/****************************************************************************************
--Switch data back to main table
*****************************************************************************************/


ALTER TABLE [dbo].PartitionedTable_Switch
	SWITCH PARTITION 1
TO [dbo].PartitionedTable
	PARTITION 1;
GO


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	p.partition_number, p.partition_id, 
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
--Add constraint to switch table
*****************************************************************************************/


ALTER TABLE dbo.PartitionedTable_Switch 
		ADD CONSTRAINT CreatedDate_CHECK CHECK 
			(CreatedDate < '2013-01-01');
GO


/****************************************************************************************
--Try the switch again
*****************************************************************************************/


ALTER TABLE [dbo].PartitionedTable_Switch
	SWITCH PARTITION 1
TO [dbo].PartitionedTable
	PARTITION 1;
GO


/****************************************************************************************
--Check data in switch table
*****************************************************************************************/


SELECT COUNT(*) AS [RowCount] FROM dbo.PartitionedTable_Switch;
GO


/****************************************************************************************
--Check partitions
*****************************************************************************************/


SELECT 
	p.partition_number, p.partition_id, 
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

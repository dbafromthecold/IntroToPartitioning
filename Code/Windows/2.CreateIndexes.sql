USE [PartitioningDemo];
GO


/****************************************************************************************
--Check Partitions
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
--Create clustered index
*****************************************************************************************/


DROP INDEX IF EXISTS [IX_ID_PartitionedTable] ON dbo.PartitionedTable;

CREATE UNIQUE CLUSTERED INDEX [IX_ID_PartitionedTable] ON dbo.PartitionedTable
 (ID) 
ON PS_PartitionedTable(CreatedDate);
GO

CREATE CLUSTERED INDEX [IX_ID_PartitionedTable] ON dbo.PartitionedTable
 (ID) 
ON PS_PartitionedTable(CreatedDate);
GO


/****************************************************************************************
--Check data
*****************************************************************************************/

EXEC sp_helpfile;
GO


DBCC IND('PartitioningDemo','PartitionedTable',1);
GO


DBCC TRACEON(3604);
GO
DBCC PAGE ('PartitioningDemo',FILEID,PAGEID,3);
GO




/****************************************************************************************
--Create nonclustered index
*****************************************************************************************/


DROP INDEX IF EXISTS [IX_ID_PartitionedTable] ON dbo.PartitionedTable;
DROP INDEX IF EXISTS [IX_CreatedDate_PartitionedTable] ON dbo.PartitionedTable;


CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable] ON dbo.PartitionedTable
 (ColA) 
ON PS_PartitionedTable(CreatedDate);
GO



/****************************************************************************************
--Check data
*****************************************************************************************/


DBCC IND('PartitioningDemo','PartitionedTable',2);
GO


DBCC TRACEON(3604);
GO
DBCC PAGE ('PartitioningDemo',FILEID,PAGEID,3);
GO



/****************************************************************************************
--Recreate clustered index
*****************************************************************************************/


DROP INDEX IF EXISTS [IX_ID_PartitionedTable] ON dbo.PartitionedTable;
DROP INDEX IF EXISTS [IX_CreatedDate_PartitionedTable] ON dbo.PartitionedTable;

CREATE UNIQUE CLUSTERED INDEX [IX_CreatedDate_PartitionedTable] ON dbo.PartitionedTable
 (CreatedDate,ID) 
ON PS_PartitionedTable(CreatedDate);
GO


/****************************************************************************************
--Recreate nonclustered index
*****************************************************************************************/


DROP INDEX IF EXISTS [IX_ColA_PartitionedTable] ON dbo.PartitionedTable;

CREATE NONCLUSTERED INDEX [IX_ColA_PartitionedTable] ON dbo.PartitionedTable
 (ColA) 
ON PS_PartitionedTable(CreatedDate);
GO
CREATE TABLE dbo.PartitionedTable
	(ColA INT IDENTITY(1,1),
	 ColB VARCHAR(10),
	 ColC VARCHAR(10),
	 ColD VARCHAR(10),
	 PartitioningKey DATE)
ON PartitionScheme(PartitioningKey);

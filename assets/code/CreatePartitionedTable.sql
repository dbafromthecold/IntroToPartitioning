CREATE TABLE dbo.PartitionedTable
	(ID INT IDENTITY(1,1),
	 ColA VARCHAR(10),
	 ColB VARCHAR(10),
	 CreatedDate DATE)
ON PartitionScheme(CreatedDate);

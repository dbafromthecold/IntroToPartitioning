ALTER TABLE [Source Table]
	SWITCH PARTITION Partition_Number
TO [Destination Table]
	PARTITION Partition_Number;

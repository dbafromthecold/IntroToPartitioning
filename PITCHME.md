@title[An Introduction to Partitioning]

# An Introduction to Partitioning

## Andrew Pruski

---

@title[About me]

# Andrew Pruski

## SQL Server DBA & Microsoft Data Platform MVP

[@fa[twitter] @dbafromthecold](https://twitter.com/dbafromthecold) <br>
@color[orange](dbafromthecold@gmail.com) <br>
@color[brown](www.dbafromthecold.com)

---

@title[Session Aim]

## To give you a base of knowledge to work with partitioning in SQL Server

---

@title[Agenda]

### Agenda

1. Partitioning Definition
2. Partitioning Key
3. Partition Functions & Schemes
4. Indexing Considerations
5. Splitting, Merging & Switching Partitions
6. Implementing Sliding Windows
7. Filegroup Restores

---

@title[Partitioning Definition]

### What is partitioning?

Splitting a table horizontally into different units <br>
Units can be spread across different physical locations <br>
Limit of 15,000 partitions per table <br>
Primarily for maintenance of data <br>
Specialist functions available to manage data

---

@title[Benefits]

### Benefits

Partitioned tables appear as normal tables <br>
Data is automatically mapped to the correct partition <br>
Specialist operations allow for easy management of data <br>
Individual partitions can be compressed <br>
Individual partitions can be rebuilt

---

@title[Drawbacks]

### Drawbacks

Requires management of partitions and filegroups <br>
Specialist operations can be blocked by DML operations <br>
Foreign keys referencing partitioned table will prevent switch operations <br>
Performance of queries not referencing the partitioning key will be affected

---

@title[Building a Partitioned Table Section Header]

## Building a partitioned table

---

@title[Partitioning key]

### Partitioning key

Column in the table which defines partition boundaries <br>
How is the data going to be split? <br>
Archiving/retention policy for the data? <br>
How is the table going to be queried? <br>
All column types except timestamp, ntext, text, image, xml, varchar(max), nvarchar(max), or varbinary(max)

---

@title[Partition function]

### Parition function

#### Maps rows in the table to a partition

---?code=assets/slide_code&lang=sql&title=Partition Function

#### Maps rows in the table to a partition

---

@title[Left/Right range types]

#### Defines which side of the boundary the value specified belongs



---

@title[Partition Scheme]

### Partition Scheme

#### Maps partitions to filegroups



---

@title[Creating a partitioned table]

### Creating a partitioned table



---

@title[Demo 1]

## Demo

---

@title[Indexing Considerations Section Header]

## Indexing considerations

---

@title[Clustered Indexes]

### Clustered Indexes

Create on the partition scheme specifying the partitioning key <br>
<b>Unique</b> – the partitioning key has to be explicitly specified <br>
<b>Nonunique</b> – the partitioning key will be added by SQL if not explicitly specified

---

@title[Nonclustered Indexes]

### Nonclustered Indexes

An index that is created using the same partition scheme as the base table is <b>aligned</b> <br>
An index that is created on a different filegroup or using a different partition scheme is <b>non-aligned</b>

---

@title[Nonclustered Index cont]

### Nonclustered Indexes

<b>Unique</b> - the partitioning key has to be explicitly specified <br>
<b>Nonunique</b> - the partitioning key will be added by SQL if not  explicitly specified as an included column

---

@title[Demo 2]

## Demo

---

@title[Merging & Splitting Partitions Section Header]

## Merging & Splitting Partitions

---

@title[Merging Partitions]

### Merging Partitions

Removes a partition <br>
Effectively “merges” two partitions into one <br>
Meta-data only operation if performed on an empty partition <br>
Data will be moved if partition is not empty, causing blocking and transaction log growth

---

@title[Merging Partitions cont]
 


---

@title[Splitting Partitions]

## Splitting Partitions

Creates a new partition with new boundary value <br>
New boundary value must be distinct from other values <br>
Takes a schema modification lock on the table <br>
Meta-data only operation if partition is empty <br>
SQL will move data to the new partition if the data crosses the new boundary value

---

@title[Splitting Paritions cont]

### Spliting Partitions




---

@title[Demo 3]

## Demo

---

@title[Switching Partitions Section Header]

## Switching Partitions

---

@title[Switching Partitions]

### Switching Partitions

Move a partition from one table to another <br>
Meta-data operation, runs immediately <br>
Both tables must have the same structures <br>
Destination partition must be empty or…if destination table is not partitioned, it must be completely empty

---

@title[Switching Partitions cont]




---

@title[Demo 4]

## Demo

---

@title[Implementing Partition Sliding Windows Section Header]

## Implementing Partition Sliding Windows

---

@title[Partition Sliding Windows]

### Partition Sliding Windows 

Method to remove old data and bring in new data periodically <br>
Implements the SWITCH, MERGE, & SPLIT functions <br>
Partitions in the table move “forward” but the overall number of partitions remains the same

---

@title[Demo 5]

## Demo

---

@title[Filegroup Restores Section Header]

## Filegroup Restores

---

@title[Filegroup Restores Benefits]

### Filegroup Restores

Can be useful for VLDBs <br>
Can be used to restore live partitions to development <br>
Individual partitions are on different filegroups <br>
Data in older partitions does not change or is not needed <br> 
Reduce recovery time for “active” data

---

@title[Demo 6]

## Demo

---


@title[A quick story]

## A quick story

---

@title[Resources]

### Resources

https://github.com/dbafromthecold/IntroToPartitioning <br>
https://dbafromthecold.com/2018/02/19/summary-of-my-partitioning-series/ <br> 
https://docs.microsoft.com/en-us/sql/relational-databases/partitions/partitioned-tables-and-indexes <br> 
https://technet.microsoft.com/en-us/library/ms187526(v=sql.105).aspx

---

@title[Questions]

## Questions?

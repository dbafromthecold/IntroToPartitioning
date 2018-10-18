@title[An Introduction to Partitioning]

# Partitioning 101

---

<img src="assets\images\SQLSatMadrid/SQLSatMadridSponsors.PNG">

---

<img src="aassets\images\SQLSatMadrid/SQLSatMadridInfo.PNG">

---


@title[About me]

## Andrew Pruski

### SQL Server DBA & Microsoft Data Platform MVP

@fa[twitter] @dbafromthecold <br>
@fa[envelope] dbafromthecold@gmail.com <br>
@fa[wordpress] www.dbafromthecold.com <br>
@fa[github] github.com/dbafromthecold

\#GroupByConf

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

### @fa[thumbs-up] Benefits

Partitioned tables appear as normal tables <br>
Data is automatically mapped to the correct partition <br>
Specialist operations allow for easy management of data <br>
Individual partitions can be compressed <br>
Individual partitions can be rebuilt

---

@title[Drawbacks]

### @fa[exclamation-triangle] Drawbacks

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

---?code=assets/code/CreatePartitionFunction.sql&lang=sql&title=Partition Function

Maps rows in the table to a partition

---?code=assets/code/RightLeftPartitionBoundaries.sql&lang=sql&title=Partition Boundaries

@[1-3](Defines which side of the boundary the value specified belongs)
@[5-6](Data from & including 2017-01-01 to 2017-12-31)
@[8-9](Data from & including 2017-01-02 to 2018-01-01)

---?code=assets/code/CreatePartitionScheme.sql&lang=sql&title=Partition Scheme

@[3](<b>@color[#fffdd0](ALL)</b> maps all partitions to one filegroup)

Maps partitions to filegroups

---?code=assets/code/CreatePartitionedTable.sql&lang=sql&title=Partitioned Table

@[7] Specify partition scheme & partitioning key instead of filegroup

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
<br>
<b>@color[#fffdd0](Unique)</b> – the partitioning key has to be explicitly specified <br>
<b>@color[#fffdd0](Nonunique)</b> – the partitioning key will be added by SQL if not explicitly specified

---

@title[Nonclustered Indexes]

### Nonclustered Indexes

An index that is created using the same partition scheme as the base table is <b>@color[#fffdd0](aligned)</b> <br>
An index that is created on a different filegroup or using a different partition scheme is <b>@color[#fffdd0](non-aligned)</b>

---

@title[Nonclustered Index cont]

### Nonclustered Indexes

<b>@color[#fffdd0](Unique)</b> - the partitioning key has to be explicitly specified <br>
<b>@color[#fffdd0](Nonunique)</b> - the partitioning key will be added by SQL if not  explicitly specified as an included column

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

---?code=assets/code/MergingPartitions.sql&lang=sql&title=Merging Partitions

---

@title[Splitting Partitions]

## Splitting Partitions

Creates a new partition with new boundary value <br>
New boundary value must be distinct from other values <br>
Takes a schema modification lock on the table <br>
Meta-data only operation if partition is empty <br>
SQL will move data to the new partition if the data crosses the new boundary value

---?code=assets/code/SplittingPartitions.sql&lang=sql&title=Splitting Partitions

@[1-2](Specify which filgroup the new partition will reside on)
@[4-5](Split out new partition based on value passed in)

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

---?code=assets/code/SwitchingPartitions.sql&lang=sql&title=Switching Partitions

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
Implements the <b>@color[#fffdd0](SWITCH)</b>, <b>@color[#fffdd0](MERGE)</b>, & <b>@color[#fffdd0](SPLIT)</b> functions <br>
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

@snap[east]
![STORY](assets/images/ShortStory.png)
@snapend

@snap[west text-white]
A quick story
@snapend

---

@title[Resources]

### Resources

@size[0.6em](https://github.com/dbafromthecold/IntroToPartitioning) <br>
@size[0.6em](https://dbafromthecold.com/2018/02/19/summary-of-my-partitioning-series/) <br> 

---

@title[Questions]

## Questions?

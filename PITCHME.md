@title[An Introduction to Partitioning]

# An Introduction to Partitioning

## Andrew Pruski

---

@title[About me]

# Andrew Pruski

## SQL Server DBA & Microsoft Data Platform MVP

#### [@fa[twitter] @dbafromthecold](https://twitter.com/dbafromthecold)
#### @color[orange](dbafromthecold@gmail.com)
#### @color[brown](www.dbafromthecold.com)

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

#### Splitting a table horizontally into different units
#### Units can be spread across different physical locations
#### Limit of 15,000 partitions per table
#### Primarily for maintenance of data
#### Specialist functions available to manage data

---

@title[Benefits]

### Benefits

#### Partitioned tables appear as normal tables
#### Data is automatically mapped to the correct partition
#### Specialist operations allow for easy management of data
#### Individual partitions can be compressed
#### Individual partitions can be rebuilt

---

@title[Drawbacks]

### Drawbacks

#### Requires management of partitions and filegroups
#### Specialist operations can be blocked by DML operations
#### Foreign keys referencing partitioned table will prevent switch operations
#### Performance of queries not referencing the partitioning key will be affected

---

@title[Building a partitioned table]

## Building a partitioned table

---

@title[Partitioning key]

### Partitioning key

#### Column in the table which defines partition boundaries
#### How is the data going to be split?
#### Archiving/retention policy for the data?
#### How is the table going to be queried?
#### All column types except timestamp, ntext, text, image, xml, varchar(max), nvarchar(max), or varbinary(max)

---

@title[Partition function]

### Parition function

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


@title[Indexing Considerations]

## Indexing considerations

---


@title[Clustered Indexes]

### Clustered Indexes

####Create on the partition scheme specifying the partitioning key
<br>
####<b>Unique</b> – the partitioning key has to be explicitly specified 
####<b>Nonunique</b> – the partitioning key will be added by SQL if not

---

@title[Nonclustered Indexes]

### Nonclustered Indexes

---

@title[Demo 2]

## Demo

---

@title[Merging & Splitting partitions]

## Merging & Splitting Partitions

---

@title[Merging Partitions]

### Merging Partitions

---

@title[Merging Partitions cont]


---

@title[Splitting Partitions]

## Splitting Partitions

---

@title[Splitting Paritions cont]

### Spliting Partitions

---

@title[Demo 3]

## Demo

---

@title[Switching Partitions]

## Switching Partitions

---

@title[Switching Partitions cont]

### Switching Partitions

---

@title[Demo 4]

## Demo

---

@title[Implementing Partition Sliding Windows]

## Implementing Partition Sliding Windows

---

@title[Partition Sliding Windows]

### Partition Sliding Windows

---

@title[Demo 5]

## Demo

---

@title[Filegroup Restores]

## Filegroup Restores

---

@title[Filegroup Restores Benefits]

### Filegroup Restores

---

@title[Demo 6]

## Demo

---


@title[A quick story]

## A quick story

---


@title[Resources]

### Resources

---


@title[Questions]

## Questions?







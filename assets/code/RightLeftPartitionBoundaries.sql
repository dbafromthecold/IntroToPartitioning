CREATE PARTITION FUNCTION [MyPartitionFunction](DATE)
	AS RANGE RIGHT | LEFT
FOR VALUES (2016-01-01,2017-01-01,2018-01-01);

RIGHT
	2017-01-01 <= x < 2018-01-01

LEFT
	2017-01-01 < x <= 2018-01-01

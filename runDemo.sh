#!/bin/bash

BEELINE_PARAMETERS=$1

mvn clean package

hdfs dfs -put -f target/UdfExecutionLocationDemo-1.0.jar /tmp/

# Create table if it doesn't exist, and populate it with 80 rows, so that we have something to work with.
beeline $BEELINE_PARAMETERS -e "CREATE TABLE IF NOT EXISTS ExecutionLocationDemo(foo INT, bar STRING) STORED AS ORC;"
beeline $BEELINE_PARAMETERS -e "INSERT INTO ExecutionLocationDemo VALUES (1, 'hello'), (2, 'goodbye'), (3, 'howdy'), (4, 'ciao'), (5, 'willkommen');"
beeline $BEELINE_PARAMETERS -e "INSERT INTO ExecutionLocationDemo SELECT * FROM ExecutionLocationDemo;"
beeline $BEELINE_PARAMETERS -e "INSERT INTO ExecutionLocationDemo SELECT * FROM ExecutionLocationDemo;"
beeline $BEELINE_PARAMETERS -e "INSERT INTO ExecutionLocationDemo SELECT * FROM ExecutionLocationDemo;"
beeline $BEELINE_PARAMETERS -e "INSERT INTO ExecutionLocationDemo SELECT * FROM ExecutionLocationDemo;"

addUdfScript="ADD JAR hdfs:///tmp/UdfExecutionLocationDemo-1.0.jar;CREATE TEMPORARY FUNCTION getHostname AS 'com.test.hadoop.GetHostname';CREATE TEMPORARY FUNCTION getHostnameWithData AS 'com.test.hadoop.GetHostnameWithData';"
echo "Querying with no parameter at all. Note that this goes to the HiveServer2 Node"
beeline $BEELINE_PARAMETERS -e "$addUdfScript;SELECT DISTINCT getHostname() AS noParameter FROM ExecutionLocationDemo;"
echo "Querying with a parameter. Note that this uses the data nodes, since it cannot optimize."
beeline $BEELINE_PARAMETERS -e "$addUdfScript;SELECT DISTINCT getHostnameWithData(bar) AS withParameter FROM ExecutionLocationDemo;"
echo "Querying with a parameter, but limiting to one row. Note that this goes to the HiveServer2 node, since it can be optimized easily."
beeline $BEELINE_PARAMETERS -e "$addUdfScript;SELECT getHostnameWithData(bar) AS withParameterOneRow FROM ExecutionLocationDemo LIMIT 1;"

# UDF Execution Location Demonstration
## Background
While working with a client, we came across an error where they had run a test UDF on Hive 1.2.1 that accidentally created an empty krb5.conf file in /home/hive on the HiveServer2 node. This led us to the question of how a UDF (which I had assumed ran on the data nodes as part of the MapReduce job) would be running on the HiveServer2 node. 

This demonstration proves my initial theory on this question, which is that Hive actually optimizes queries that are small enough to run locally on the HiveServer2 instance, instead of starting up a MapReduce job. I figured this would happen when no data from the table is actually used, but this is actually the case when a small amount of data is necessary from the dataset as well.

## Explaination
This demo creates a test table, builds two custom UDFs, and then runs various commands to show how it sometimes optimizes so that the job runs on the master node, and sometimes on the data nodes. The table contains 80 rows, with an integer and a string. Both UDFs return the host name on which it is running. The second UDF also takes a string parameter, which is included in the output. This allows us to force the optimization to not happen by adding data to be passed into the UDF (thus it isn't a constant value).

Three queries are run. The first uses the no parameter version, and only returns the HiveServer2 node, since it was optimized. 

The second uses the parameter version, and shows all distinct values. This version returns multiple from the data nodes, since it could not be optimized. Due to the small nature of the data, I am seeing all calls coming from the same node, but YMMV.

The third is the same as the second, but removes the DISTINCT parameter, and sets LIMIT 1. This allows for optimization, and we see a single value from the HiveServer2 node.

## Usage
To run the demo, clone this repository down to a node, and run the included script runDemo.sh. The script takes one parameter, which are the parameters to be passed to beeline. For example, on my demo cluster, this is how it was run:

```bash
./runDemo.sh '-u "jdbc:hive2://mst1.test.hadoop.com:2181,dat1.test.hadoop.com:2181,dat2.test.hadoop.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2;hiveuser=hive" -n hive'
```

This demo was tested on an HDP 2.6.5 test cluster, built using the vagrant box [here](https://github.com/davidov541/HadoopOnVagrant/tree/master/HDP2.6.X-CentOS7). I make no promises that this behavior is the same in later versions of Hive, including those included in HDP 3.X, CDH, and CDP.

# kafkaDemo

# Install Kafka

**see debiziumdemo project/postgres-kafka and uinversal-payload-generator for more info**

## With docker-compose.yml

https://github.com/debezium/debezium-examples/blob/master/tutorial/docker-compose-postgres.yaml

`docker-compose up zookeeper`

`docker-compose up kafka`

`docker-compose up postgres`

`docker-compose up connect` 

`docker-compose ps`

OUTPUT:
```sh
    Name                  Command              State                                Ports
----------------------------------------------------------------------------------------------------------------------
connect        /docker-entrypoint.sh start     Up      0.0.0.0:8083->8083/tcp, 8778/tcp, 9092/tcp, 9779/tcp
deb_postgres   docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp
kafka          /docker-entrypoint.sh start     Up      8778/tcp, 0.0.0.0:9092->9092/tcp, 9779/tcp
zookeeper      /docker-entrypoint.sh start     Up      0.0.0.0:2181->2181/tcp, 0.0.0.0:2888->2888/tcp,
```
                                                     0.0.0.0:3888->3888/tcp, 8778/tcp, 9779/tcp
check kafka-connect:
`url -H "Accept:application/json" localhost:8083/`
{"version":"2.4.0","commit":"77a89fcf8d7fa018","kafka_cluster_id":"4zDsU771QMS_rZQr8LHTkw"}%


**Without docker-cpmpose.yml**
Debizium docker images:
https://github.com/debezium/docker-images/tree/master/postgres

https://medium.com/@tilakpatidar/streaming-data-from-postgresql-to-kafka-using-debezium-a14a2644906d


Start a PostgreSQL instance:
`docker run -it --rm --name postgres -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres debezium/example-postgres:1.0`

Start a Zookeeper instance:
`docker run -it --rm --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 debezium/zookeeper:1.0`


Start a Kafka instance:
`docker run -it --rm --name kafka -p 9092:9092 --link zookeeper:zookeeper debezium/kafka:1.0`

Start a Debezium instance (connect):
`docker run -it --rm --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my-connect-configs -e OFFSET_STORAGE_TOPIC=my-connect-offsets -e ADVERTISED_HOST_NAME=$(echo $DOCKER_HOST | cut -f3 -d'/' | cut -f1 -d':') --link zookeeper:zookeeper --link postgres:postgres --link kafka:kafka debezium/connect:1.0`

Connect to postgres container and create inventory db:

`docker exec -it postgres psql -U postgres`

in `postgres=#` prompt execute following:

```sql
\l

CREATE DATABASE inventory;

\c inventory

CREATE TABLE customers
(
  id bigint NOT NULL,
  first_name VARCHAR (50),
  last_name VARCHAR (50) NOT NULL,
  email VARCHAR (355) UNIQUE NOT NULL,
  CONSTRAINT pk_customers PRIMARY KEY (id)
);

\d customers

insert into customers values(1001, 'sally', 'thomas', 's.t@acme.com');
insert into customers values(1002, 'george', 'bailey', 'g.b@acme.com');
insert into customers values(1003, 'edward', 'walker', 'e.w@acme.com');

select * from public.customers;
```

OUPTPUT:

check database:
`postgres> \list`
\c inventory
```sql
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)


create database inventory;
```

use inventory:

`postgres-# \c inventory`
FATAL:  database "inventory" does not exist

```sql
postgres=# create database inventory;
CREATE DATABASE

postgres=# \c inventory;
You are now connected to database "inventory" as user "postgres".

inventory=# \dt;
Did not find any relations.

postgres=# 
CREATE TABLE customers(
   id INT PRIMARY KEY,
   first_name VARCHAR (50),
   last_name VARCHAR (50) NOT NULL,
   email VARCHAR (355) UNIQUE NOT NULL
);

CREATE TABLE

inventory=# \dt;
           List of relations
 Schema |   Name    | Type  |  Owner
--------+-----------+-------+----------
 public | customers | table | postgres
(1 row)

inventory=# insert into customers values(1001, 'sally', 'thomas', 's.t@acme.com');
INSERT 0 1
inventory=# insert into customers values(1002, 'george', 'bailey', 'g.b@acme.com');
INSERT 0 1
inventory=# insert into customers values(1003, 'edward', 'walker', 'e.w@acme.com');
INSERT 0 1

inventory=# select * from customers;
    id |    first_name |    last_name |      email
-------+---------------+--------------+--------------
  1001 | sally         | thomas       | s.t@acme.com
  1002 | george        | bailey       | g.b@acme.com
  1003 | edward        | walker       | e.w@acme.com
(3 rows)
```

https://hub.docker.com/r/debezium/postgres



## install kafka on local mac:

`$ brew cask install java` - i skipped this. i had openjdk installed.

`$ brew install kafka`

This will install kafka on : `/usr/local/Cellar/kafka/`

contents of bin folder(these are the scripts/commands avaialbe):

```sh
(base)  rdissanayakam@RBH12855  /usr/local/Cellar/kafka/2.4.1/bin  ls
connect-distributed              kafka-configs                    kafka-delegation-tokens          kafka-mirror-maker               kafka-run-class                  kafka-verifiable-consumer        zookeeper-server-stop
connect-mirror-maker             kafka-console-consumer           kafka-delete-records             kafka-preferred-replica-election kafka-server-start               kafka-verifiable-producer        zookeeper-shell
connect-standalone               kafka-console-producer           kafka-dump-log                   kafka-producer-perf-test         kafka-server-stop                trogdor
kafka-acls                       kafka-consumer-groups            kafka-leader-election            kafka-reassign-partitions        kafka-streams-application-reset  zookeeper-security-migration
kafka-broker-api-versions        kafka-consumer-perf-test         kafka-log-dirs                   kafka-replica-verification       kafka-topics                     zookeeper-server-start
```

the poroperies files are located at `/usr/local/Cellar/kafka/2.4.1/libexec/config`: 

```sh
(base)  rdissanayakam@RBH12855  /usr/local/Cellar/kafka/2.4.1  ls libexec
bin    config libs   logs
(base)  rdissanayakam@RBH12855  /usr/local/Cellar/kafka/2.4.1  ls libexec/config
connect-console-sink.properties   connect-file-sink.properties      connect-mirror-maker.properties   log4j.properties                  tools-log4j.properties
connect-console-source.properties connect-file-source.properties    connect-standalone.properties     producer.properties               trogdor.conf
connect-distributed.properties    connect-log4j.properties          consumer.properties               server.properties                 zookeeper.properties
```

### Start Zookeeper:
`zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties`

### Start Kafka server:
`kafka-server-start /usr/local/etc/kafka/server.properties`

During server start, you might be facing connection broken issue.

```sh
[2018-08-28 16:24:41,166] WARN [Controller id=0, targetBrokerId=0] Connection to node 0 could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2018-08-28 16:24:41,268] WARN [Controller id=0, targetBrokerId=0] Connection to node 0 could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
```

To fix this issue, we need to change the server.properties file.
`$ vim /usr/local/etc/kafka/server.properties`
Here uncomment the server settings and update the value from
`listeners=PLAINTEXT://:9092`
to
```sh
############################# Socket Server Settings #############################
# The address the socket server listens on. It will get the value returned from 
# java.net.InetAddress.getCanonicalHostName() if not configured.
#   FORMAT:
#     listeners = listener_name://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092
listeners=PLAINTEXT://localhost:9092
```
and restart the server and it will work great.

If you get the error `InconsistentClusterIdException: The Cluster ID z7KWdJyvQauQHEjzR7JErw doesn't match stored clusterId Some(ABmFXLNBTB-i9xatRD-Faw) in meta.properties. The broker is trying to join the wrong cluster`

- Just Delete all the log/Data file created (or generated) into zookeeper and kafka.
    **kafka :**
    logs dir is mentioned in `/usr/local/etc/kafka/server.properties`:
    ```sh
    # A comma separated list of directories under which to store log files
    log.dirs=/usr/local/var/lib/kafka-logs
    ```
    delete logs dir content:
    ```sh
    base)  rdissanayakam@RBH12855  ~  `rm -rf /usr/local/var/lib/kafka-logs/*`
    zsh: sure you want to delete all 6 files in /usr/local/var/lib/kafka-logs [yn]? y
    ```
    **zookeeper**
    data dir in `/usr/local/etc/kafka/zookeeper.properties`
    ```sh
    # the directory where the snapshot is stored.
    dataDir=/usr/local/var/lib/zookeeper
    ```
    delete:
    ```sh
    base)  ✘ rdissanayakam@RBH12855  /usr/local/var/lib/kafka-logs  rm -rf /usr/local/var/lib/zookeeper/*
    zsh: sure you want to delete the only file in /usr/local/var/lib/zookeeper [yn]? y
    (base)  rdissanayakam@RBH12855  /usr/local/var/lib/zookeeper 
    ```


- Run Zookeper

- Run Kafka

## Create Kafka Topic:

topic members

`kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic  members`

## List kafka topics:
`kafka-topics --list --bootstrap-server localhost:9092`

ooutput:
```sh
__consumer_offsets
member
```

## Initialize Producer console:
Now we will initialize the Kafka producer console, which will listen to localhost at port 9092 at topic members :

`kafka-console-producer --broker-list localhost:9092 --topic members`

output:

```sh
$ kafka-console-producer --broker-list localhost:9092 --topic members
>send first message
>send second message
>wow it is working
```

## Initialize Consumer console:
Now we will initialize the Kafka consumer console, which will listen to bootstrap server localhost at port 9092 at topic members from beginning:

`kafka-console-consumer --bootstrap-server localhost:9092 --topic members --from-beginning`

```sh
$ kafka-console-consumer --bootstrap-server localhost:9092 --topic members --from-beginning
send first message
send second message
wow it is working
```

To stop kafka broker:
`kafka-server-stop`
`zookeeper-server-stop`

## Troubleshoot 

### kafka broker will not stop

fix:
find process id of kafka borker
`lsof -t -i :9092`
then `kill -9 <PID>`

```sh
(base)  ✘ rdissanayakam@RBH12855  ~  lsof -t -i :9092
48370
(base)  rdissanayakam@RBH12855  ~  kill -9 48370
(base)  rdissanayakam@RBH12855  ~ 
```

## add plugin for postgres

Place PostgreSQL JDBC driver placed into /kafka/libs directory:
`(base)  rdissanayakam@RBH12855  /usr/local/Cellar/kafka/2.4.1/libexec/libs  wget https://jdbc.postgresql.org/download/postgresql-42.2.11.jar`

Create directory for debezium plugins:
`mkdir -p debezium_plugins`

`cd debezium_plugins`

Place debezium postgres plugin in debezium_plugins:
`wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/1.0.0.Final/debezium-connector-postgres-1.0.0.Final-plugin.tar.gz`

`tar -xzf debezium-connector-postgres-1.0.0.Final-plugin.tar.gz`

Place 

download kafka-connect confluent jdbc connector: https://docs.confluent.io/current/connect/connect-jdbc/docs/index.html
and move to debezium_plugins


`vi /usr/local/Cellar/kafka/2.4.1/libexec/config/connect-standalone.properties`

add and save:
`plugin.path=/Users/rdissanayakam/debezium_plugins`

`vi /usr/local/Cellar/kafka/2.4.1/libexec/config/connect-distributed.properties`

add and save:
`plugin.path=/Users/rdissanayakam/debezium_plugins`

## run kafka connector
`connect-standalone /usr/local/Cellar/kafka/2.4.1/libexec/config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties`


TODO....


## create connector for rds
https://debezium.io/blog/2017/09/25/streaming-to-another-database/

```json
curl -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '
{
 "name": "inventory-connector",
 "config": {
 "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
 "tasks.max": "1",
 "database.hostname": "ras-db.c4dsc34i9waw.us-east-1.rds.amazonaws.com",
 "database.port": "5432",
 "database.user": "testUser",
 "database.password": "testPassword",
 "database.dbname" : "genesis",
 "database.server.name": "dbserver1",
 "database.whitelist": "genesis",
 "database.history.kafka.bootstrap.servers": "kafka:9092",
 "database.history.kafka.topic": "schema-changes.genesis"
 }
}'
```


# Debizium with Postgres RDS

## create ec2 instance 

I used :
- Amazon Linux 2 AMI (HVM), SSD Volume Type - ami-0fc61db8544a617ed (64-bit x86) / ami-0f90a34c9df977efb (64-bit Arm)
- t2.small
- securtiy group : allow allincoming tcp from anybody ::0

## log into ec2 instance

`ssh -i "dmrhimali_keypair.pem" ec2-user@ec2-52-4-164-216.compute-1.amazonaws.com`

## install java
`sudo yum -y install java-1.8.0-openjdk`

## install kafka

get a mirror link for latest dowmload binary tar.gz from https://kafka.apache.org/downloads

for latest version 2.4.1 the site https://www.apache.org/dyn/closer.cgi?path=/kafka/2.4.1/kafka_2.11-2.4.1.tgz
recommends mirror: http://mirror.metrocast.net/apache/kafka/2.4.1/kafka_2.11-2.4.1.tgz

`wget http://mirror.metrocast.net/apache/kafka/2.4.1/kafka_2.11-2.4.1.tgz`

This downloads kafka_2.11-2.4.1.tgz

Extract:

`tar -xzf kafka_2.11-2.4.1.tgz`

this will extract content to a folder kafka_2.11-2.4.1.

## install zookeeper

cd into the kafka directory

`cd kafka_2.11-2.4.1`

We now need a single node zookeeper server (the script for which is provided by the good folks at Apache Kafka). So, you don’t have to worry about installing it separately.

If you have zookeeper version > 3.5.3,  four Letter Words need to be explicitly white listed before using:

`vi config/zookeeper.properties`
add line and save:
`4lw.commands.whitelist=*`

## Run zookeeper
kickoff zookeeper in background:
`bin/zookeeper-server-start.sh -daemon config/zookeeper.properties`

Install netcat:
`sudo yum install nmap`

This installs `ncat`.

Running the following ruok command, should return an **imok**.
`echo "ruok" | ncat localhost 2181`

output:
```sh
[ec2-user@ip-172-31-45-35 kafka_2.11-2.4.1]$ echo "ruok" |  ncat localhost 2181
imok
```

This tells you that zookeeper is alive and well! See [other four letter words](https://zookeeper.apache.org/doc/r3.4.8/zookeeperAdmin.html#sc_zkCommands)

check zookeeper is runnig :

`ps aux | grep zoo`


## Run kafka

Now, we are ready to start up the Kafka server. 

###  Set up the advertised.listeners config parameter
If you are **NOT** connecting to the topic from the same machine set up the advertised.listeners config parameter in the server.properties file (/home/ec2-user/kafka_2.11-2.4.1/config/server.properties).

advertised.listeners=PLAINTEXT://<kafkahostname>:9092

If you are connecting to the topic from the same machine, you don’t need this step.

To start the Kafka server, run: 
`bin/kafka-server-start.sh -daemon config/server.properties`

Once the Kafka server is up, proceed to create a topic.
`bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test`

List topics:

`bin/kafka-topics.sh --list --zookeeper localhost:2181`

output
```sh
__consumer_offsets
numtest
test
```

Now that the topic is ready to receive messages, test it using the producer and consumer scripts that are packaged within Kafka.

If you want to connect to the topic programmatically, skip this section and move on to the next one.

### simple test

Use the producer script to publish messages to your new topic.

`bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test`

Enter some messages at prompt:

```sh
>Message One
>Message Two
>Message Three
```

output:
```sh
[ec2-user@ip-172-31-45-35 kafka_2.11-2.4.1]$ bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
>Message one
>Message two
>Message three
```

You then run the consumer to see those messages.

ssh to ec2 instance in a different terminal and run:

`cd cd kafka_2.11-2.4.1/`

`bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning`

prints :
  Message One
  Message Two
  Message Three

output:

```sh
[ec2-user@ip-172-31-45-35 kafka_2.11-2.4.1]$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
Message one
Message two
Message three
```

Any additional messages sent via the producer will automatically show up on the consumer console window.

### Publishing messages using kafka-python

kafka-python is one of the python clients for Apache Kafka.
You can install it using pip.

install pip:
`sudo yum install python-pip`

install kafka-python:
`sudo pip install kafka-python`

To publish a message on to the topic and test, create a KafkaProducer and use the send method to publish a sample message.

**producer.py**

```python
from time import sleep
from json import dumps
from kafka import KafkaProducer

producer = KafkaProducer(bootstrap_servers=['localhost:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

for e in range(1000):
    data = {'number' : e}
    producer.send('numtest', value=data)
    sleep(5)                         
```
Run producer:
`python ./producer.py`


**consumer.py**

```python
from kafka import KafkaConsumer
from json import loads

consumer = KafkaConsumer(
    'numtest',
     bootstrap_servers=['localhost:9092'],
     auto_offset_reset='earliest',
     enable_auto_commit=True,
     group_id='my-group',
     value_deserializer=lambda x: loads(x.decode('utf-8')))

for message in consumer:
    message = message.value
    print('read message: {}'.format(message))
```
In a new ec2 terminal run consumer:
`python ./consumer.py`

The new message should now appear on the consumer console that you have running from the previous section.

```sh
[ec2-user@ip-172-31-45-35 ~]$ python ./consumer.py
read message: {u'number': 0}
read message: {u'number': 1}
read message: {u'number': 2}
...
```

If you prefer a UI to look at the messages in the topic, there are a few options such as Landoop, Cloudkarafka, KafkaTool and others.

## Install kafka connect

http://kafka.apache.org/documentation.html#connect

Kafka Connect is a tool for scalably and reliably streaming data between Apache Kafka and other systems. It makes it simple to quickly define connectors that move large collections of data into and out of Kafka. Kafka Connect can ingest entire databases or collect metrics from all your application servers into Kafka topics, making the data available for stream processing with low latency. An export job can deliver data from Kafka topics into secondary storage and query systems or into batch systems for offline analysis

Kafka Connect currently supports two modes of execution: 
 - standalone (single process) and 
 - distributed.

In standalone mode all work is performed in a single process. This configuration is simpler to setup and get started with and may be useful in situations where only one worker makes sense (e.g. collecting log files), but it does not benefit from some of the features of Kafka Connect such as fault tolerance. 

To start a standalone Kafka Connector, we need following three configuration files.
- connect-standalone.properties
- connect-file-source.properties
- connect-file-sink.properties

**config/connect-file-source.properties**
```sh
name=local-file-source
connector.class=FileStreamSource
tasks.max=1
file=test.txt
topic=connect-test
```

**config/connect-file-sink.properties**
```sh
name=local-file-sink
connector.class=FileStreamSink
tasks.max=1
file=test.sink.txt
topics=connect-test
```

https://www.tutorialkart.com/apache-kafka/apache-kafka-connector/ 

Kafka by default provides these configuration files in config folder. We shall use those config files as is. If you go through those config files, you may find in connect-file-source.properties, that the file is test.txt, which we have created in our first step. Run the following command from the kafka directory to start a Kafka Standalone Connecto

Let us test if kafka-connect works:

create connect-test topic:
`bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic connect-test`

create test.txt needed for config/connect-file-source.properties in kafka folder with content:
```sh
Hello!
Welcome to TutorialKart
Learn Apache Kafka
```

Now start a standalone process with the following command:
`bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties`

Observe `test.sync.txt` created next to `test.txt`

Once the Connector is started, initially the data in test.txt would be synced to test.sync.txt and the data is published to the Kafka Topic named, connect-test. Then any changes to the test.txt file would be synced to test.sync.txt and published to connect-test topic. Add a new line, ” Learn Connector with Example” to test.txt.

```sh
echo "Learn Connector" >> test.txt
~/kafka_2.12-1.0.0$ cat test.sink.txt
Hello!
Welcome to TutorialKart
Learn Apache Kafka
Learn Connector
```

Now Consume the messages posted to connect-test topic by a Consumer.

We shall start a Consumer and consume the messages (test.txt and additions to test.txt). Following is a Kafka Console Consumer. You may create [Kafka Consumer of your application choice](https://www.tutorialkart.com/apache-kafka/kafka-consumer-with-example-java-application/).

`bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning`

output:
```sh
[ec2-user@ip-172-31-45-35 kafka_2.11-2.4.1]$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
{"schema":{"type":"string","optional":false},"payload":"Hello!"}
{"schema":{"type":"string","optional":false},"payload":"Welcome to TutorialKart"}
{"schema":{"type":"string","optional":false},"payload":"Learn Apache Kafka"}
{"schema":{"type":"string","optional":false},"payload":""}
{"schema":{"type":"string","optional":false},"payload":"Learn Connector"}

```

## install debizium

### download and extract postgres connector to ec2
https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/

`mkdir -p /home/ec2-user/plugins`
`cd /home/ec2-user/plugins`

`wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/1.0.0.Final/debezium-connector-postgres-1.0.0.Final-plugin.tar.gz`

`tar -xzf debezium-connector-postgres-1.0.0.Final-plugin.tar.gz`

This extract to folder `debezium-connector-postgres`

move to plugins
`mv debezium-connector-postgres plugins`

update plugin path in connect-distributed properties:
`vi kafka_2.11-2.4.1/config/connect-distributed.properties`
add and save:
`plugin.path=/home/ec2-user/plugins`

update plugin path in connect-standalone properties:
`vi kafka_2.11-2.4.1/config/connect-standalone.properties`
add and save:
`plugin.path=/home/ec2-user/plugins`

Restart your Kafka Connect process to pick up the new JARs [http://kafka.apache.org/documentation.html#connect](see here).

Option1 : restart standalone connector
`bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties`

Option2 : restart distributed connector [i just went with rerunning standalone connector. not this.]
`bin/connect-distributed.sh config/connect-distributed.properties`

you may need to restart kafka service if kafka connect throws errors.

curl -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d ' { "name": "genesis-member-connector", "config": { "connector.class": "io.debezium.connector.postgresql.PostgresConnector", "tasks.max": "1", "database.hostname": "postgres", "database.port": "5432", "database.user": "testUser", "database.password": "testPassword", "database.dbname" : "genesis", "database.server.name": "dbserver1", "database.whitelist": "genesis", "database.history.kafka.bootstrap.servers": "kafka:9092", "database.history.kafka.topic": "schema-changes.inventory" } }'



### Using a Debezium Connector

https://debezium.io/documentation/reference/install.html

To use a connector to produce change events for a particular source server/cluster, simply create a configuration file for the [Postgres Connector]( https://debezium.io/documentation/reference/connectors/postgresql.html#deploying-a-connector) and use the Kafka Connect REST API to add that connector configuration to your Kafka Connect cluster. When the connector starts, it will connect to the source and produce events for each inserted, updated, and deleted row or document.

See the Debezium Connectors documentation for more information.

## Topics and Partitions

Messages in Kafka are categorized into **topics**.

Topics are additionally broken down into a number of **partitions**.

Going back to the “commit log” description, a partition is a sin‐ gle log. Messages are written to it in an append-only fashion, and are read in order from beginning to end. Note that as a topic typically has multiple partitions, there is no guarantee of message time-ordering across the entire topic, just within a single partition

# Kafka-Springboot

https://www.confluent.io/blog/apache-kafka-spring-boot-application/

https://dzone.com/articles/magic-of-kafka-with-spring-boot

https://www.baeldung.com/spring-kafka


https://www.javainuse.com/spring/spring-boot-apache-kafka-hello-world


Developers,

As we continue to advance our Kafka development strategies, with developer experience in mind, we come to the first Avro and Avro Schema Migration guidelines to help keep everyone on a similar page. 

Event Avro Schema Will be defined in Kotlin using the [Avro4k](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2Favro-kotlin%2Favro4k&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487419089%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=rldNMlyRF8onEelB7FdYAVJc0ET0gTnnl5%2FtrHKx8Ls%3D&reserved=0) libraries. 

A Gradle plugin will generate the Avro Schema from code [Avro4k Build Plugin](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2FMagusDevOps%2Favro4k-build-plugins&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487419089%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=GKz3UraS1OHE2EN0sqWPq9KOn7nvrK7U%2FReOJteayDg%3D&reserved=0).

Schema Will be validated on pull requests (IN PROGRES) for comparability for Stage and Production using [ImFlog Schema Registry Plugin()]. 
Schema Will be validated on pull requests (IN PROGRES) for comparability for Stage and Production using [ImFlog Schema Registry Plugin](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2FImFlog%2Fschema-registry-plugin&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487429084%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=J6rj636sFgsWng9HjE2sWnk6XbzUJxFvBPdxlVtv5WE%3D&reserved=0). 

The schema will use compatibility of "FORWARD" on stage and production environments as that level matches the closest to the way things currently work with SNS and SQS.

Deployment of Schemas is currently manual using the [ImFlog Schema Registry Plugin](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2FImFlog%2Fschema-registry-plugin&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487429084%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=J6rj636sFgsWng9HjE2sWnk6XbzUJxFvBPdxlVtv5WE%3D&reserved=0), but the CI pipeline method is a work-in-progress.

Generic Documentation: [Kafka Schema Registry Quick Start](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fconfluence.virginpulse.com%2Fdisplay%2FBUL%2FKafka%2BSchema%2BRegistry%2BDeveloper%2BQuick%2BStart&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487439080%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=kp8asngNM7k76h4dNwYloi63BzCMxjzJcSxuoNO99Gg%3D&reserved=0)

Project Example: [Data Ingestion Example](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgit.virginpulse.com%2Fengineering%2Fgenesis-data-ingestion%2Fdata-ingestion%2F-%2Fmerge_requests%2F667&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487449071%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=QrNTq8XiseuVGp4EkaviiswF6Hz1TLWGxu%2F0fLRtRuQ%3D&reserved=0)

Extras: [ImFlog Schema Registry Plugin ](https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2FImFlog%2Fschema-registry-plugin&data=04%7C01%7CRasanjalee.Dissanayaka%40virginpulse.com%7Cc7dcfa713fba494fedc708d8cd136479%7Cb123a16e892b4cf6a55a6f8c7606a035%7C0%7C0%7C637484830487449071%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=%2BYa2sWxFec0x4nCjF76jUh2G0mYAgWcTmhYe0UDsybo%3D&reserved=0)


note: you don't need to check in the Avro files as they will automatically be generated during first compile

Please reach out with any feedback or concerns.

Thanks,
Jacob
#!/bin/bash

# Variables
KAFKA_USER="kafka"
KAFKA_GROUP="kafka"
KAFKA_TAR="kafka_2.13-3.4.0.tgz"
KAFKA_INSTALL_DIR="/home/$KAFKA_USER/kafka_2.13-3.4.0"
KAFKA_CONF_DIR="$KAFKA_INSTALL_DIR/config"
KAFKA_DATA_DIR="/data1/kafka-logs"
KAFKA_CERTS_DIR="/data/kafka_certs"
KAFKA_CFG_FILE="$KAFKA_CONF_DIR/server.properties"
KAFKA_JAASCONF_FILE="$KAFKA_CONF_DIR/kafka_jaas.conf"

# Create a user and group named 'KAFKA'
sudo groupadd $KAFKA_GROUP
sudo useradd -m -g $KAFKA_GROUP $KAFKA_USER

# Extract the KAFKA tar file into the desired directory
sudo -u $KAFKA_USER mkdir -p $KAFKA_INSTALL_DIR
sudo tar -xzf $KAFKA_TAR -C /home/$KAFKA_USER
sudo chown -R $KAFKA_USER:$KAFKA_GROUP $KAFKA_INSTALL_DIR

# Create the directory to store KAFKA data,logs and certificates
sudo mkdir -p $KAFKA_DATA_DIR
sudo mkdir -p $KAFKA_CERTS_DIR
sudo rm -r /home/kafka/kafka_2.13-3.4.0/config/server.properties
sudo cp keystore.jks truststore.jks $KAFKA_CERTS_DIR
sudo cp cruise-control-metrics-reporter-2.5.139-SNAPSHOT.jar /home/kafka/kafka_2.13-3.4.0/libs/
sudo chown -R $KAFKA_USER:$KAFKA_GROUP $KAFKA_DATA_DIR
sudo chown -R $KAFKA_USER:$KAFKA_GROUP $KAFKA_CERTS_DIR


# Create the server.properties file in the conf directory
sudo bash -c "cat > $KAFKA_JAASCONF_FILE" <<EOF
KafkaServer {
org.apache.kafka.common.security.scram.ScramLoginModule required
username="admin"
password="sd";
};
KafkaClient {
org.apache.kafka.common.security.scram.ScramLoginModule required
username="admin"
password="asd";
};
EOF



# Create the server.properties file in the conf directory
sudo bash -c "cat > $KAFKA_CFG_FILE" <<EOF
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# see kafka.server.KafkaConfig for additional details and defaults

############################# Server Basics #############################

# The id of the broker. This must be set to a unique integer for each broker.
broker.id=1

############################# Socket Server Settings #############################

# The address the socket server listens on. It will get the value returned from 
# java.net.InetAddress.getCanonicalHostName() if not configured.
#   FORMAT:
#     listeners = listener_name://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092

listeners=SASL_SSL://0.0.0.0:6667,CLIENT://0.0.0.0:9003,CLIENT_GCP://0.0.0.0:9103
listener.security.protocol.map=SASL_SSL:SASL_SSL,CLIENT:SASL_SSL,CLIENT_GCP:SASL_SSL
advertised.listeners=SASL_SSL://host1:6667,CLIENT://prod-rrabroker.ril.com:9003,CLIENT_GCP://prod-rrabroker3.ril.com:9103

# Hostname and port the broker will advertise to producers and consumers. If not set, 
# it uses the value for "listeners" if configured.  Otherwise, it will use the value
# returned from java.net.InetAddress.getCanonicalHostName().
#advertised.listeners=PLAINTEXT://your.host.name:9092

# Maps listener names to security protocols, the default is for them to be the same. See the config documentation for more details
#listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

authorizer.class.name=kafka.security.authorizer.AclAuthorizer
sasl.enabled.mechanisms=SCRAM-SHA-512
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-512
security.inter.broker.protocol=SASL_SSL
ssl.client.auth=required
ssl.endpoint.identification.algorithm=
ssl.key.password=7ecETGlHjzs
ssl.keystore.location=/data/kafka_certs/keystore.jks
ssl.keystore.password=7ecETGlHjzs
ssl.truststore.location=/data/kafka_certs/truststore.jks
ssl.truststore.password=7ecETGlHjzs
super.users=User:admin

# The number of threads that the server uses for receiving requests from the network and sending responses to the network
num.network.threads=3

# The number of threads that the server uses for processing requests, which may include disk I/O
num.io.threads=8

# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=102400

# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=102400

# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=104857600


############################# Log Basics #############################

# A comma separated list of directories under which to store log files
log.dirs=/data1/kafka-logs

# The default number of log partitions per topic. More partitions allow greater
# parallelism for consumption, but this will also result in more files across
# the brokers.
num.partitions=1

# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.
# This value is recommended to be increased for installations with data dirs located in RAID array.
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings  #############################
# The replication factor for the group metadata internal topics "__consumer_offsets" and "__transaction_state"
# For anything other than development testing, a value greater than 1 is recommended for to ensure availability such as 3.
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

############################# Log Flush Policy #############################

# Messages are immediately written to the filesystem but by default we only fsync() to sync
# the OS cache lazily. The following configurations control the flush of data to disk.
# There are a few important trade-offs here:
#    1. Durability: Unflushed data may be lost if you are not using replication.
#    2. Latency: Very large flush intervals may lead to latency spikes when the flush does occur as there will be a lot of data to flush.
#    3. Throughput: The flush is generally the most expensive operation, and a small flush interval may lead to excessive seeks.
# The settings below allow one to configure the flush policy to flush data after a period of time or
# every N messages (or both). This can be done globally and overridden on a per-topic basis.

# The number of messages to accept before forcing a flush of data to disk
#log.flush.interval.messages=10000

# The maximum amount of time a message can sit in a log before we force a flush
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################

# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion due to age
log.retention.hours=72

# A size-based retention policy for logs. Segments are pruned from the log unless the remaining
# segments drop below log.retention.bytes. Functions independently of log.retention.hours.
#log.retention.bytes=1073741824

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
log.segment.bytes=1073741824

# The interval at which log segments are checked to see if they can be deleted according
# to the retention policies
log.retention.check.interval.ms=300000

############################# Zookeeper #############################

# Zookeeper connection string (see zookeeper docs for details).
# This is a comma separated host:port pairs, each corresponding to a zk
# server. e.g. "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002".
# You can also append an optional chroot string to the urls to specify the
# root directory for all kafka znodes.
zookeeper.connect=sidcrrakfk02.ril.com:2181,sidcrrakfk03.ril.com:2181,sidcrrakfk04.ril.com:2181

# Timeout in ms for connecting to zookeeper
zookeeper.connection.timeout.ms=6000 


############################# Group Coordinator Settings #############################

# The following configuration specifies the time, in milliseconds, that the GroupCoordinator will delay the initial consumer rebalance.
# The rebalance will be further delayed by the value of group.initial.rebalance.delay.ms as new members join the group, up to a maximum of max.poll.interval.ms.
# The default value for this is 3 seconds.
# We override this to 0 here as it makes for a better out-of-the-box experience for development and testing.
# However, in production environments the default value of 3 seconds is more suitable as this will help to avoid unnecessary, and potentially expensive, rebalances during application startup.
group.initial.rebalance.delay.ms=0 
metric.reporters=com.linkedin.kafka.cruisecontrol.metricsreporter.CruiseControlMetricsReporter
cruise.control.metrics.topic.auto.create=true
cruise.control.metrics.topic.num.partitions=1
cruise.control.metrics.topic.replication.factor=1
cruise.control.metrics.reporter.ssl.truststore.location = /datasdada/asd/truststore.jks
cruise.control.metrics.reporter.ssl.truststore.password = 7ecETGlHjzs
cruise.control.metrics.reporter.ssl.protocol=TLS
cruise.control.metrics.reporter.security.protocol=SASL_SSL
cruise.control.metrics.reporter.sasl.mechanism=SCRAM-SHA-512
cruise.control.metrics.reporter.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="password";

#####ADDITIONAL SETTINGS AS PER OLD KAFKA CONFIGURATION#############
auto.create.topics.enable=false
auto.leader.rebalance.enable=true
compression.type=producer
controlled.shutdown.enable=true
controlled.shutdown.max.retries=3
controlled.shutdown.retry.backoff.ms=5000
controller.message.queue.size=10
controller.socket.timeout.ms=30000
default.replication.factor=1
delete.topic.enable=true
leader.imbalance.check.interval.seconds=300
leader.imbalance.per.broker.percentage=10
log.cleanup.interval.mins=10
log.index.interval.bytes=4096
log.index.size.max.bytes=10485760
log.retention.bytes=-1
log.retention.hours=72
log.roll.hours=168
log.segment.bytes=1073741824
message.max.bytes=5000000
min.insync.replicas=1
num.replica.fetchers=1
offset.metadata.max.bytes=4096
offsets.commit.required.acks=-1
offsets.commit.timeout.ms=5000
offsets.load.buffer.size=5242880
offsets.retention.check.interval.ms=600000
offsets.retention.minutes=86400000
offsets.topic.compression.codec=0
offsets.topic.num.partitions=50
offsets.topic.replication.factor=3
offsets.topic.segment.bytes=104857600
producer.metrics.enable=false
producer.purgatory.purge.interval.requests=10000
queued.max.requests=500
replica.fetch.max.bytes=5048576
replica.fetch.min.bytes=1
replica.fetch.wait.max.ms=500
replica.high.watermark.checkpoint.interval.ms=5000
replica.lag.max.messages=4000
replica.lag.time.max.ms=10000
replica.socket.receive.buffer.bytes=65536
replica.socket.timeout.ms=30000
socket.request.max.bytes=104857600
zookeeper.session.timeout.ms=30000
zookeeper.sync.time.ms=2000
EOF

# Change ownership of the server.properties file to the KAFKA user
sudo chown $KAFKA_USER:$KAFKA_GROUP $KAFKA_CFG_FILE
sudo chown $KAFKA_USER:$KAFKA_GROUP $KAFKA_JAASCONF_FILE

echo "Apache KAFKA has been installed and configured for the KAFKA user."
echo "Data directory created at $KAFKA_DATA_DIR."
echo "CERTS directory created at $KAFKA_DATA_DIR."
echo "KAFKA configuration file created at $KAFKA_CFG_FILE

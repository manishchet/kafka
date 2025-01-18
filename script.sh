
#script to create topic by passin the topic names in text file#----------------

#!/bin/bash
unset JMX_PORT
unset JMX_PROMETHEUS_PORT
unset KAFKA_JMX_OPTS
input="topics.txt"
while IFS=, read -r line part1 repl
do
  echo "$line","$part1","$repl"
/home/kafka/kafka_2.13-3.4.0/bin/kafka-topics.sh --create --topic "$line" --partitions "$part1" --replication-factor "$repl" --command-config /root/admin.properties --bootstrap-server  hostname1r1.ril.com:6667
done < "$input"



#script to create username and password-----------
#!/bin/bash
unset JMX_PORT
unset JMX_PROMETHEUS_PORT
unset KAFKA_JMX_OPTS
/root/kafka_2.13-3.4.0/bin/kafka-configs.sh --zookeeper hostname1r1.ril.com:2181 --alter --add-config 'SCRAM-SHA-512=[password='$2']' --entity-type users --entity-name $1

#script to give producing rights-----------
#!/bin/bash
unset JMX_PORT
unset JMX_PROMETHEUS_PORT
unset KAFKA_JMX_OPTS
/root/kafka_2.13-3.4.0/bin/kafka-acls.sh --authorizer-properties zookeeper.connect=hostname1r1.ril.com:2181 --add --allow-principal User:$1 --producer --topic $2 --resource-pattern-type prefixed


#script to give consuming rights-----------
#!/bin/bash
unset JMX_PORT
unset JMX_PROMETHEUS_PORT
unset KAFKA_JMX_OPTS
/root/kafka_2.13-3.4.0/bin/kafka-acls.sh --authorizer-properties zookeeper.connect=hostname1r1.ril.com:2181  --add --allow-principal User:$1  --consumer --group $1  --topic $2 --resource-pattern-type prefixed

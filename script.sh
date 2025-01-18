
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


###script to create certificates
#!/bin/bash

# Generates several self signed keys <name>.cer, <name>.jks, and <name>.p12.
# Truststore is set with name truststore.jks and set password of password12345

# Usage: createKey.sh <user> <password>
# Example: createKey.sh somebody password123

NAME="$1"
PASSWORD="7ecETGlHjzs"
STORE_PASSWORD="7ecETGlHjzs"

echo "Creating key for $NAME using password $PASSWORD"

keytool -genkey -alias "$NAME" -keyalg RSA -keysize 4096 -dname "CN=$NAME,OU=ABC,O=ABC,L=ABC,ST=ABC,C=IN" -ext "SAN=DNS:$NAME" -keypass "$PASSWORD" -keystore "$NAME.jks" -storepass "$PASSWORD" -validity 3650

keytool -importkeystore -srckeystore "$NAME.jks" -destkeystore "$NAME.p12" -srcstoretype JKS -deststoretype PKCS12 -srcstorepass "$PASSWORD" -deststorepass "$PASSWORD" -srcalias "$NAME" -destalias "$NAME" -srckeypass "$PASSWORD" -destkeypass "$PASSWORD" -noprompt

keytool -export -keystore "$NAME.jks" -storepass "$PASSWORD" -alias "$NAME" -file "$NAME.cer"

keytool -import -trustcacerts -file "$NAME.cer" -alias "$NAME" -keystore "truststore.jks" -storepass "$STORE_PASSWORD" -noprompt

echo "Done creating key for $NAME"

keytool -list -keystore "truststore.jks" -storepass "7ecETGlHjzs" -noprompt

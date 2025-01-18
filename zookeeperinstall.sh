#!/bin/bash

# Variables
ZOOKEEPER_USER="zookeeper"
ZOOKEEPER_GROUP="zookeeper"
ZOOKEEPER_TAR="apache-zookeeper-3.8.4-bin.tar.gz"  # Update this path if necessary
ZOOKEEPER_INSTALL_DIR="/home/$ZOOKEEPER_USER/apache-zookeeper-3.8.4-bin"
ZOOKEEPER_CONF_DIR="$ZOOKEEPER_INSTALL_DIR/conf"
ZOOKEEPER_DATA_DIR="/data1/zk-data"
HOSTNAMES=("$@")
ZOOKEEPER_VERSION="3.8.4"

# ZooKeeper ensemble details
ENSEMBLE_CONFIG="
server.1=sjdcrradlkkfk1.ril.com:2888:3888
server.2=sjdcrradlkkfk2.ril.com:2888:3888
server.3=sjdcrradlkkfk3.ril.com:2888:3888"

if [ ${#HOSTNAMES[@]} -ne 3 ]; then
  echo "Please provide exactly 3 hostnames as arguments."
  exit 1
fi

# Function to install and configure ZooKeeper on each node
install_zookeeper_on_node() {
  local HOSTNAME=$1
  local MYID=$2

  echo "Installing ZooKeeper on $HOSTNAME with myid=$MYID"

  # Copy the ZooKeeper tar file to the target node
  scp $ZOOKEEPER_TAR root@$HOSTNAME:/root/

  # Run the installation commands on the target node
  ssh root@$HOSTNAME bash -s <<EOF
    # Create the zookeeper user and group if they don't exist
    if ! id -u $ZOOKEEPER_USER >/dev/null 2>&1; then
      groupadd $ZOOKEEPER_GROUP
      useradd -m -g $ZOOKEEPER_GROUP $ZOOKEEPER_USER
    fi

    # Extract the ZooKeeper tar file into the desired directory
    sudo -u $ZOOKEEPER_USER mkdir -p $ZOOKEEPER_INSTALL_DIR
    tar -xzf /root/$ZOOKEEPER_TAR -C /home/$ZOOKEEPER_USER
    chown -R $ZOOKEEPER_USER:$ZOOKEEPER_GROUP $ZOOKEEPER_INSTALL_DIR

    # Create the directory to store ZooKeeper data and logs
    mkdir -p $ZOOKEEPER_DATA_DIR
    chown -R $ZOOKEEPER_USER:$ZOOKEEPER_GROUP $ZOOKEEPER_DATA_DIR

    # Create the myid file with the appropriate value
    echo "$MYID" | tee $ZOOKEEPER_DATA_DIR/myid > /dev/null
    chown $ZOOKEEPER_USER:$ZOOKEEPER_GROUP $ZOOKEEPER_DATA_DIR/myid

    # Create the zoo.cfg file
    cat > $ZOOKEEPER_CONF_DIR/zoo.cfg <<EOL
tickTime=3000
syncLimit=5
initLimit=10
dataDir=$ZOOKEEPER_DATA_DIR
clientPort=2181
maxClientCnxns=120
$ENSEMBLE_CONFIG
EOL

    chown $ZOOKEEPER_USER:$ZOOKEEPER_GROUP $ZOOKEEPER_CONF_DIR/zoo.cfg

    # Create the java.env file in the conf directory with the specified heap size
    echo "export ZK_SERVER_HEAP=1024" > $ZOOKEEPER_CONF_DIR/java.env
    chown $ZOOKEEPER_USER:$ZOOKEEPER_GROUP $ZOOKEEPER_CONF_DIR/java.env

    # Create the systemd service file for ZooKeeper
    cat > /etc/systemd/system/zookeeper.service <<EOL
[Unit]
Description=Zookeeper server
Requires=network.target
After=network.target

[Service]
Type=forking
User=zookeeper
PIDFile=/data1/zk-data/zookeeper_server.pid
ExecStart=/home/zookeeper/apache-zookeeper-3.8.4-bin/bin/zkServer.sh start
ExecStop=/home/zookeeper/apache-zookeeper-3.8.4-bin/bin/zkServer.sh stop
RestartSec=30s
[Install]
WantedBy=default.target
EOL

    # Reload systemd, enable and start the ZooKeeper service
    systemctl daemon-reload
    systemctl enable zookeeper
    systemctl status zookeeper

    echo "ZooKeeper installation, configuration, and service setup complete on $HOSTNAME."
EOF
}

# Loop through hostnames and install ZooKeeper with the appropriate myid
for i in "${!HOSTNAMES[@]}"; do
  install_zookeeper_on_node "${HOSTNAMES[$i]}" $((i+1))
done

echo "ZooKeeper installation, configuration, and service setup completed on all nodes."

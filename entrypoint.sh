#!/bin/bash

NODE_ID=${HOSTNAME:6}
LISTENERS="INTERNAL://:9092,CONTROLLER://:9093,EXTERNAL://:9094"
ADVERTISED_LISTENERS="INTERNAL://kafka-$NODE_ID.$SERVICE.$NAMESPACE.svc.cluster.local:9092,EXTERNAL://kafka-$NODE_ID.cluster.local:9094"
LISTENER_SECURITY_PROTOCOL_MAP="INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT"
INTER_BROKER_LISTENER_NAME="INTERNAL"

CONTROLLER_QUORUM_VOTERS=""
for i in $(seq 0 $REPLICAS); do
    if [[ $i != $REPLICAS ]]; then
        CONTROLLER_QUORUM_VOTERS="$CONTROLLER_QUORUM_VOTERS$i@kafka-$i.$SERVICE.$NAMESPACE.svc.cluster.local:9093,"
    else
        CONTROLLER_QUORUM_VOTERS=${CONTROLLER_QUORUM_VOTERS::-1}
    fi
done

mkdir -p $KAFKA_LOG_DIRS/$NODE_ID

sed -i "
    s|^node.id=.*|node.id=$NODE_ID|g
    s|^controller.quorum.voters=.*|controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS|g
    s|^listeners=.*|listeners=$LISTENERS|g
    s|^inter.broker.listener.name=.*|inter.broker.listener.name=$INTER_BROKER_LISTENER_NAME|g
    s|^advertised.listeners=.*|advertised.listeners=$ADVERTISED_LISTENERS|g
    s|^listener.security.protocol.map=.*|listener.security.protocol.map=$LISTENER_SECURITY_PROTOCOL_MAP|g
    s|^log.dirs=.*|log.dirs=$KAFKA_LOG_DIRS/$NODE_ID|g
    " /opt/kafka/config/kraft/server.properties

CLUSTER_ID=$(kafka-storage.sh random-uuid)
kafka-storage.sh format -t $CLUSTER_ID -c /opt/kafka/config/kraft/server.properties

exec kafka-server-start.sh /opt/kafka/config/kraft/server.properties
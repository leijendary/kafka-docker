#!/bin/bash

export NODE_ID=${HOSTNAME:6}
export CONTROLLER_QUORUM_VOTERS=""

for i in $(seq 0 $REPLICAS); do
    if [[ $i != $REPLICAS ]]; then
        export CONTROLLER_QUORUM_VOTERS="$CONTROLLER_QUORUM_VOTERS$i@kafka-$i.$SERVICE.$NAMESPACE.svc.cluster.local:9093,"
    else
        export CONTROLLER_QUORUM_VOTERS=${CONTROLLER_QUORUM_VOTERS::-1}
    fi
done

mkdir -p $KAFKA_LOG_DIRS/$NODE_ID

if [[ -f "$KAFKA_LOG_DIRS/cluster_id" ]]; then
    CLUSTER_ID=$(cat $KAFKA_LOG_DIRS/cluster_id)
else
    CLUSTER_ID=$(kafka-storage.sh random-uuid)
    echo $CLUSTER_ID > $KAFKA_LOG_DIRS/cluster_id
fi

envsubst < "/opt/kafka/config/kraft/server.properties" > "/opt/kafka/config/kraft/server.properties.updated"
mv /opt/kafka/config/kraft/server.properties.updated /opt/kafka/config/kraft/server.properties

kafka-storage.sh format -t $CLUSTER_ID -c /opt/kafka/config/kraft/server.properties

exec kafka-server-start.sh /opt/kafka/config/kraft/server.properties
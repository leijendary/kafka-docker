#!/bin/sh
cd /$FILE_NAME/config/kraft
sed -i "s|^node.id=.*|node.id=$KAFKA_NODE_ID|g" server.properties
sed -i "s|^controller.quorum.voters=.*|controller.quorum.voters=$KAFKA_CONTROLLER_QUORUM_VOTERS|g" server.properties
sed -i "s|^log.dirs=.*|log.dirs=$KAFKA_LOG_DIRS|g" server.properties
sed -i "s|^listeners=.*|listeners=$KAFKA_LISTENERS|g" server.properties
sed -i "s|^inter.broker.listener.name=.*|inter.broker.listener.name=$KAFKA_INTER_BROKER_LISTENER_NAME|g" server.properties
sed -i "s|^advertised.listeners=.*|advertised.listeners=$KAFKA_ADVERTISED_LISTENERS|g" server.properties
sed -i "s|^controller.listener.names=.*|controller.listener.names=$KAFKA_CONTROLLER_LISTENER_NAMES|g" server.properties
sed -i "s|^listener.security.protocol.map=.*|listener.security.protocol.map=$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP|g" server.properties
sed -i "s|^log.retention.hours=.*|log.retention.hours=$KAFKA_LOG_RETENTION_HOURS|g" server.properties

cd /$FILE_NAME
RANDOM_UUID=$(./bin/kafka-storage.sh random-uuid)
./bin/kafka-storage.sh format -t $RANDOM_UUID -c ./config/kraft/server.properties
./bin/kafka-server-start.sh ./config/kraft/server.properties
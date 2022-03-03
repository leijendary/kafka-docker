FROM openjdk:17-slim
RUN apt-get update && apt-get -y install wget && rm -rf /var/cache/apt/archives
ENV SCALA_VERSION=2.13
ENV KAFKA_VERSION=3.1.0
ENV FILE_NAME=kafka_${SCALA_VERSION}-${KAFKA_VERSION}
RUN wget -qO- https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/${FILE_NAME}.tgz | tar -xvz
ENV KAFKA_NODE_ID=1
ENV KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka:9093
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV KAFKA_LISTENERS=EXTERNAL://:9092,INTERNAL://:29092,CONTROLLER://:9093
ENV KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL
ENV KAFKA_ADVERTISED_LISTENERS=EXTERNAL://localhost:9092,INTERNAL://kafka:29092
ENV KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
ENV KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT,INTERNAL:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL
ENV KAFKA_LOG_RETENTION_HOURS=168
ENV KAFKA_HEAP_OPTS="-Xms512m -Xmx512m"
CMD cd /$FILE_NAME/config/kraft ;\
    sed -i "s|^node.id=.*|node.id=$KAFKA_NODE_ID|g" server.properties ;\
    sed -i "s|^controller.quorum.voters=.*|controller.quorum.voters=$KAFKA_CONTROLLER_QUORUM_VOTERS|g" server.properties ;\
    sed -i "s|^log.dirs=.*|log.dirs=$KAFKA_LOG_DIRS|g" server.properties ;\
    sed -i "s|^listeners=.*|listeners=$KAFKA_LISTENERS|g" server.properties ;\
    sed -i "s|^inter.broker.listener.name=.*|inter.broker.listener.name=$KAFKA_INTER_BROKER_LISTENER_NAME|g" server.properties ;\
    sed -i "s|^advertised.listeners=.*|advertised.listeners=$KAFKA_ADVERTISED_LISTENERS|g" server.properties ;\
    sed -i "s|^controller.listener.names=.*|controller.listener.names=$KAFKA_CONTROLLER_LISTENER_NAMES|g" server.properties ;\
    sed -i "s|^listener.security.protocol.map=.*|listener.security.protocol.map=$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP|g" server.properties ;\
    sed -i "s|^log.retention.hours=.*|log.retention.hours=$KAFKA_LOG_RETENTION_HOURS|g" server.properties ;\
    cd /$FILE_NAME ;\
    RANDOM_UUID=$(./bin/kafka-storage.sh random-uuid) ;\
    sh ./bin/kafka-storage.sh format -t $RANDOM_UUID -c ./config/kraft/server.properties ;\
    sh ./bin/kafka-server-start.sh ./config/kraft/server.properties


FROM eclipse-temurin:17-jre
RUN apt-get update && apt-get -y install wget gettext-base && rm -rf /var/cache/apt/archives
ENV SCALA_VERSION=2.13
ENV KAFKA_VERSION=3.1.0
ENV KAFKA_HOME=/opt/kafka
ENV PATH=${PATH}:${KAFKA_HOME}/bin
RUN mkdir $KAFKA_HOME
RUN wget -qO- https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz | tar -C $KAFKA_HOME --strip 1 -xvz
ENV KAFKA_BROKER_PASSWORD=broker-password
ENV KAFKA_CLIENT_PASSWORD=client-password
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV KAFKA_LOG_RETENTION_HOURS=168
ENV KAFKA_HEAP_OPTS="-Xms512m -Xmx512m"
COPY ./config/server.properties /opt/kafka/config/kraft/
COPY ./config/kafka_broker_jaas.conf /opt/kafka/config/
COPY ./entrypoint.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

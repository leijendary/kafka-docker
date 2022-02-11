docker volume create --name kafka_data
docker network create kafka_network
docker build --platform "linux/arm64" -t kafka:3.1.0 .
docker run --name kafka -p 9092:9092 -p 29092:29092 -p 9093:9093 --mount source=kafka_data,target=/var/lib/kafka/data --network=kafka_network -d kafka:3.1.0
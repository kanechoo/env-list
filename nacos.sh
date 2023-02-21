#!/bin/sh
CONTAINER=nacos
NETWORK=localhost
VOLUME=nacos-volume
IMAGE=nacos/nacos-server
TAG=v2.2.0-slim

# Check if the network exists
if ! docker network inspect $NETWORK > /dev/null 2>&1; then
  # Create the network if it doesn't exist
  echo "Creating network $NETWORK"
  docker network create $NETWORK
else
  echo "Network $NETWORK already exists , skip network create"
fi

# docker pull nacos server image
if docker images --format '{{.Repository}}:{{.Tag}}'| grep $IMAGE:$TAG; then
  echo "$IMAGE:$TAG already exists , skip image pull"
  else
    docker pull $IMAGE:$TAG
fi

# docker create volume
if docker volume ls --format '{{.Name}}'|grep $VOLUME; then
   echo "docker volume name $VOLUME already exist , skip volume create"
   else
     docker volume create $VOLUME
fi

# docker start container
if docker ps --format '{{.Image}}'|grep $IMAGE:TAG; then
  echo "$IMAGE:$TAG already in use , skip docker start $CONTAINER"
  else
    docker run --name $CONTAINER --network $NETWORK \ 
    --env-file nacos.env \
    -v $VOLUME:/home/nacos \
    -p 8848:8848 -d $IMAGE:$TAG
fi
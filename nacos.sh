#!/bin/sh
CONTAINER=nacos
NETWORK=localhost
VOLUME=nacos-volume
IMAGE=nacos/nacos-server
TAG=v2.2.0-slim

# Check if the network exists
if docker network ls --format '{{.Name}}'| grep $NETWORK > /dev/null 2>&1; then
  echo "Network $NETWORK already exists,skip network create"
else
  docker network create $NETWORK
fi

# docker pull nacos server image
if docker images --format '{{.Repository}}:{{.Tag}}'| grep $IMAGE:$TAG > /dev/null 2>&1; then
  echo "Image $IMAGE:$TAG already exists,skip image pull"
  else
    docker pull $IMAGE:$TAG
fi

# docker create volume
if docker volume ls --format '{{.Name}}'|grep $VOLUME > /dev/null 2>&1; then
   echo "Volume $VOLUME already exists,skip volume create"
   else
     docker volume create $VOLUME
fi

# docker start container
if docker ps --format '{{.Image}}'|grep $IMAGE:$TAG > /dev/null 2>&1; then
  echo "Image $IMAGE:$TAG already in use,container name : $(docker ps --format '{{.Image}} {{.Names}}'|grep $IMAGE:$TAG|awk '{print $2}')"
  else
    if docker container ls -a --format '{{.Image}}' | grep $IMAGE:$TAG > /dev/null 2>&1; then
       container_name=$(docker container ls -a --format '{{.Image}} {{.Names}}'|grep $IMAGE:$TAG|awk '{print $2}')
       echo "Start exited container $container_name"
       docker start $container_name
       else
         echo "Start new container $CONTAINER"
         docker run --name $CONTAINER --network $NETWORK --env-file=nacos.env -v $VOLUME:/home/nacos -p 8848:8848 -d $IMAGE:$TAG
    fi
fi
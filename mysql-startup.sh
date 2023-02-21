#!/bin/sh

# docker conatiner name
CONTAINER=mysql
# docker network for current container
NETWORK=localhost
# docker volume for container persist data
VOLUME=mysql-volume
# docker container image
IMAGE=mysql/mysql-server
# docker container image tag
TAG=8.0.32-amd64
# docker container env file
ENV_FILE=mysql-startup.env
# docker container listen on local machine port
PORT=3306

# Network
if docker network ls --format '{{.Name}}' | grep $NETWORK >/dev/null 2>&1; then
  echo "Network $NETWORK already exists,skip network create"
else
  docker network create $NETWORK
fi

# Image
if docker images --format '{{.Repository}}:{{.Tag}}' | grep $IMAGE:$TAG >/dev/null 2>&1; then
  echo "Image $IMAGE:$TAG already exists,skip image pull"
else
  docker pull $IMAGE:$TAG
fi

# Volume
if docker volume ls --format '{{.Name}}' | grep $VOLUME >/dev/null 2>&1; then
  echo "Volume $VOLUME already exists,skip volume create"
else
  docker volume create $VOLUME
fi

# Container
if docker ps --format '{{.Image}}' | grep $IMAGE:$TAG >/dev/null 2>&1; then
  echo "Image $IMAGE:$TAG already in use,container name : $(docker ps --format '{{.Image}} {{.Names}}' | grep $IMAGE:$TAG | awk '{print $2}')"
else
  if docker container ls -a --format '{{.Image}}' | grep $IMAGE:$TAG >/dev/null 2>&1; then
    container_name=$(docker container ls -a --format '{{.Image}} {{.Names}}' | grep $IMAGE:$TAG | awk '{print $2}')
    echo "Start exited container $container_name"
    docker start "$container_name"
  else
    echo "Start new container $CONTAINER"
    docker run --name $CONTAINER --network $NETWORK --env-file=$ENV_FILE -v $VOLUME:/var/lib/mysql -p $PORT:3306 -d $IMAGE:$TAG
  fi
fi

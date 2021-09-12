#!/usr/bin/env bash

set -ex

# dockerhub username
REGISTRY=shubhamtatvamasi

MAGMA_ROOT=${PWD}/magma
PUBLISH=${MAGMA_ROOT}/orc8r/tools/docker/publish.sh

# Cloning magma repo:
git clone https://github.com/magma/magma.git --depth 1

cd ${MAGMA_ROOT}
MAGMA_TAG=$(git rev-parse --short HEAD)--$(date +%m-%d-%Y--%H-%M-%S)

# Deleting docker login code block:
sed -i '65,71d' ${PUBLISH}

# Building Orchestrator docker images:
cd ${MAGMA_ROOT}/orc8r/cloud/docker
./build.py --all

# Pushing Orchestrator docker images:
for image in controller nginx
do
  ${PUBLISH} -r ${REGISTRY} -i ${image} -v ${MAGMA_TAG}
done

# Building NMS docker image:
cd ${MAGMA_ROOT}/nms/packages/magmalte
docker-compose build magmalte

# Pushing NMS docker image:
COMPOSE_PROJECT_NAME=magmalte ${PUBLISH} -r ${REGISTRY} -i magmalte -v ${MAGMA_TAG}

# Building Federation Gateway docker images:
cd ${MAGMA_ROOT}/feg/gateway/docker
docker-compose build --parallel

# Pushing Federation Gateway docker images:
for image in gateway_python gateway_go
do
  ${PUBLISH} -r ${REGISTRY} -i ${image} -v ${MAGMA_TAG}
done

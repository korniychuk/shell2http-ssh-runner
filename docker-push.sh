#!/usr/bin/env bash

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin "$DOCKER_PRIVATE_REGISTRY"
docker push "$DOCKER_PRIVATE_REGISTRY/shell2http-ssh-runner"

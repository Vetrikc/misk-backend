#!/bin/bash

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

SERVICES=("api-gateway" "auth-service" "user-service" "music-service" "s3-service" "recommendation-service")

echo "Building all services in parallel..."

for service in "${SERVICES[@]}"; do
    docker compose build $service &
done

wait

echo "All services built! Starting..."
docker compose up -d
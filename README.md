# MISK backend

Work-in-progress backend for a music platform built as a set of Spring Boot services.

This repository is an experiment with a larger multi-module setup rather than a finished product. The current structure includes separate services for authentication, users, music, recommendations, S3-compatible storage and an API gateway.

## Current structure

- api-gateway
- auth-service
- user-service
- music-service
- recommendation-service
- s3-service

The project also includes local PostgreSQL instances, Redis and Kafka in Docker Compose.

## Stack

Java 21, Spring Boot, Gradle, PostgreSQL, Redis, Kafka, Docker and OpenTelemetry/Micrometer.

## Running locally

Create an environment file:

```bash
cp .env.example .env
```

Then run:

```bash
docker compose up --build
```

## Status

Work in progress. Some services are still incomplete, so I do not consider this repository production-ready or part of my main portfolio yet.

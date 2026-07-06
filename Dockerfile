# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jdk-alpine AS base
WORKDIR /app

RUN apk add --no-cache dos2unix

ENV GRADLE_USER_HOME=/root/.gradle
# Найдите эту строку в вашем Dockerfile и замените на такую:
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Dorg.gradle.jvmargs=\"-Xmx512m -XX:MaxMetaspaceSize=384m\""

FROM base AS dependencies

COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle ./
COPY --parents services/*/*.gradle ./

RUN dos2unix gradlew && chmod +x gradlew

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew dependencies --no-daemon || true

FROM dependencies AS builder

ARG SERVICE_NAME

COPY . .

RUN dos2unix gradlew && chmod +x gradlew

RUN --mount=type=cache,target=/root/.gradle/${SERVICE_NAME} \
    ./gradlew :services:${SERVICE_NAME}:bootJar --no-daemon -x test

FROM eclipse-temurin:21-jre-alpine AS runner
WORKDIR /app

ARG SERVICE_NAME

COPY --from=builder /app/services/${SERVICE_NAME}/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-XX:+UseG1GC", "-XX:+ExitOnOutOfMemoryError", "-jar", "app.jar"]
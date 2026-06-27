# syntax=docker/dockerfile:1

ARG SERVICE_NAME
ARG GRADLE_CACHE_DIR

################################################################################
# Stage 1: Dependencies cache layer
FROM eclipse-temurin:26-jdk-alpine AS deps

WORKDIR /build

# Install tools
RUN apk add --no-cache wget

# Copy Gradle wrapper
COPY gradlew .
COPY gradle ./gradle
RUN chmod +x gradlew

# Copy configuration files
COPY gradle.properties .
COPY build.gradle .
COPY settings.gradle .
COPY buildSrc ./buildSrc

# Download dependencies
RUN --mount=type=cache,target=${GRADLE_CACHE_DIR} \
    ./gradlew dependencies --no-daemon || true

################################################################################
# Stage 2: Build specific service
FROM deps AS builder

ARG SERVICE_NAME
ARG GRADLE_CACHE_DIR

WORKDIR /build

# Copy all services source code
COPY services ./services

# Build only the required service
RUN --mount=type=cache,target=${GRADLE_CACHE_DIR} \
    ./gradlew :services:${SERVICE_NAME}:bootJar -x test --no-daemon && \
    cp services/${SERVICE_NAME}/build/libs/*.jar /build/app.jar

################################################################################
# Stage 3: Extract layers
FROM builder AS extractor

WORKDIR /app

COPY --from=builder /build/app.jar .
RUN java -Djarmode=layertools -jar app.jar extract --destination extracted

################################################################################
# Stage 4: Runtime
FROM eclipse-temurin:26-jre-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache wget && \
    addgroup -S appuser && adduser -S appuser -G appuser

USER appuser

COPY --from=extractor --chown=appuser:appuser /app/extracted/dependencies/ ./
COPY --from=extractor --chown=appuser:appuser /app/extracted/spring-boot-loader/ ./
COPY --from=extractor --chown=appuser:appuser /app/extracted/snapshot-dependencies/ ./
COPY --from=extractor --chown=appuser:appuser /app/extracted/application/ ./

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
# https://www.dockersecurity.io/blog/dockerize-java-26-with-docker-init

# syntax=docker/dockerfile:1

################################################################################
# Stage 1: resolve and download dependencies
FROM eclipse-temurin:26-jdk-alpine AS deps

WORKDIR /build

COPY gradle.properties ./
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

RUN chmod +x gradlew

RUN --mount=type=cache,target=/root/.gradle/caches \
    ./gradlew dependencies --no-daemon

################################################################################
# Stage 2: build the application
FROM deps AS package

COPY src src/

RUN --mount=type=cache,target=/root/.gradle/caches \
    ./gradlew bootJar -x test --no-daemon && \
    mv build/libs/*.jar app.jar

################################################################################
# Stage 3: extract Spring Boot laye
FROM package AS extractor

WORKDIR /app

COPY --from=package /build/app.jar ./
RUN java -Djarmode=layertools -jar app.jar extract --destination extracted

################################################################################
# Stage 4: minimal runtime image
FROM eclipse-temurin:26-jre-alpine AS final

WORKDIR /app

RUN addgroup -S appuser && adduser -S appuser -G appuser

USER appuser

COPY --from=extractor /app/extracted/dependencies/ ./
COPY --from=extractor /app/extracted/spring-boot-loader/ ./
COPY --from=extractor /app/extracted/snapshot-dependencies/ ./
COPY --from=extractor /app/extracted/application/ ./

EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
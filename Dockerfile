# syntax=docker/dockerfile:1

##### 1. Build #####
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /build

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B dependency:go-offline

COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B clean package -DskipTests

##### 2. Layer-Extraktion #####
FROM eclipse-temurin:25-jre-alpine AS extract
WORKDIR /extract
COPY --from=build /build/target/*.jar application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

##### 3. Runtime #####
FROM eclipse-temurin:25-jre-alpine
WORKDIR /application

RUN addgroup -S app && adduser -S -G app app

# Reihenfolge = Änderungshäufigkeit: selten zuerst, häufig zuletzt
COPY --from=extract --chown=app:app /extract/extracted/dependencies/          ./
COPY --from=extract --chown=app:app /extract/extracted/spring-boot-loader/    ./
COPY --from=extract --chown=app:app /extract/extracted/snapshot-dependencies/ ./
COPY --from=extract --chown=app:app /extract/extracted/application/           ./

USER app:app

ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError"

EXPOSE 8080 8081

HEALTHCHECK --interval=10s --timeout=3s --start-period=40s --retries=5 \
  CMD wget -qO /dev/null http://localhost:8081/actuator/health/readiness || exit 1

ENTRYPOINT ["java", "-jar", "application.jar"]

LABEL org.opencontainers.image.source="https://github.com/robin-kroczek/oauth2-reference-server" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="OAuth2 Reference Server"
FROM eclipse-temurin:23-jdk AS build
WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

COPY common/build.gradle.kts common/
COPY auth/build.gradle.kts auth/
COPY auth-service/build.gradle.kts auth-service/
COPY user/build.gradle.kts user/

RUN ./gradlew dependencies --no-daemon

COPY . .

RUN ./gradlew :inventory-service:bootJar -x test --no-daemon

FROM eclipse-temurin:23-jre
WORKDIR /app

RUN useradd -ms /bin/bash springuser
USER springuser

COPY --from=build /app/inventory-service/build/libs/inventory-service.jar app.jar

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=staging", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "app.jar"]

EXPOSE 8080
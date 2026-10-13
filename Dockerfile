
FROM maven:3.9.11-eclipse-temurin-17 AS builder

WORKDIR /workspace

# Install the shared Maven parent inside the Docker build
COPY gwatcho-maven-parent/pom.xml /tmp/gwatcho-maven-parent/pom.xml

RUN mvn -B -f /tmp/gwatcho-maven-parent/pom.xml install -N

# Copy and build only the payment service
COPY gwatcho-payment-service/pom.xml /workspace/gwatcho-payment-service/pom.xml
COPY gwatcho-payment-service/src /workspace/gwatcho-payment-service/src

RUN mvn -B -f /workspace/gwatcho-payment-service/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /workspace/gwatcho-payment-service/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

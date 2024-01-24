FROM openjdk:17-jdk-bullseye
LABEL maintainer="Platform Team Blue Yonder"

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Create a user; it must not be ROOT and its UID should be greater than 1000.
RUN groupadd --gid 1100 "stratosphere" && \
    useradd --create-home --no-log-init --shell "/bin/bash" --uid 1100 --gid 1100 "stratosphere"
USER 1100

COPY build/javaApmAgent/elastic-apm-agent.jar /home/nonroot/elastic-apm-agent.jar

ENV ELASTIC_APM_SERVICE_NAME=plan-sop-feature-toggle
ENV ELASTIC_APM_APPLICATION_PACKAGES=com.blueyonder.featuretoggle
ENV ELASTIC_APM_ENABLE_LOG_CORRELATION=true

ARG RELEASE_VERSION=*
WORKDIR /home/stratosphere
ARG JAR_FILE=build/libs/plan-sop-feature-toggle-1.0.0.jar
COPY ${JAR_FILE} app.jar

ARG DEPENDENCY=build/dependency

#CMD java $JAVA_ARGS -jar -Dspring.profiles.active=production ./app.jar
CMD ["sh", "-c", "java -javaagent:/home/nonroot/elastic-apm-agent.jar -Delastic.apm.service_name=$ELASTIC_APM_SERVICE_NAME -Delastic.apm.application_packages=$ELASTIC_APM_APPLICATION_PACKAGES -Delastic.apm.enable.log.correlation=$ELASTIC_APM_ENABLE_LOG_CORRELATION -Dspring.profiles.active=production -XX:MinRAMPercentage=75 -XX:MaxRAMPercentage=90 -jar ./app.jar"]

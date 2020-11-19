FROM openjdk:8u275-jdk

EXPOSE 8080

MAINTAINER Cho Sanghyun

VOLUME /tmp

ARG JAR_FILE=./build/libs/*.jar

COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
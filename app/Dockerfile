FROM openjdk:8u275-jdk

EXPOSE 8080

MAINTAINER Cho Sanghyun

RUN touch /tmp/healthy

ARG UNAME=user

ARG UID=1000

ARG GID=1000

RUN groupadd -g $GID -o $UNAME

RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME

VOLUME /tmp

ARG JAR_FILE=./build/libs/*.jar

COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]

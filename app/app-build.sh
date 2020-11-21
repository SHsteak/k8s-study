#! /bin/bash
docker-compose run --rm gradle gradle build
#version=$(expr $shver + 1)
docker build -t was:latest .
#export shver=$version
exit 0

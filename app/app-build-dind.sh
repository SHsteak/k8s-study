#! /bin/bash
docker run --rm -u gradle -u 1000 --privileged=true -v "$PWD":/home/gradle/project -v "$PWD"/.gradle-caches:/home/gradle/.gradle/caches -w /home/gradle/project gradle gradle $1
exit 0

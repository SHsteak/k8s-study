#! /bin/bash

dockerName="choshsh/spring-petclinic-data-jdbc:latest"

echo '' && echo '' && echo ''
echo '#############'
echo '### Build jar'
echo '#############'
echo ''
docker-compose run --rm gradle gradle build

echo '' && echo '' && echo ''
echo '######################'
echo '### Build docker image'
echo '######################'
echo ''
docker build -t $dockerName .

echo '' && echo '' && echo ''
echo '##################################'
echo '### Push docker iamge to dockerhub'
echo '##################################'
echo ''
docker push $dockerName

exit 0

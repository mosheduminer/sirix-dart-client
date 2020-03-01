echo "starting the docker environment"
docker-compose -f ./test_resources/docker-compose.yml up -d keycloak
./test_resources/wait.sh
sleep 5
docker-compose -f ./test_resources/docker-compose.yml up -d server
sleep 5

echo "preparing to run tests"
pub run test

echo "killing the docker environment"
docker-compose -f ./test_resources/docker-compose.yml kill
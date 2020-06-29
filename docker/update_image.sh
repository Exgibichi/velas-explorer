docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images topoyr/velas-explorer-test -q)
docker pull topoyr/velas-explorer-test
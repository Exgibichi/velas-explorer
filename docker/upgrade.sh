git pull
pm2 stop explorer
docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker rmi $(docker images topoyr/velas-explorer-prod -q)
docker pull topoyr/velas-explorer-prod
make postgres
pm2 start explorer

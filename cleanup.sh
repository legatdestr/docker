echo 'Clean up the exited containers ...';     docker rm -v $(docker ps -a -q -f status=exited);
echo 'Remove unwanted ‘dangling’ images ...';  docker rmi $(docker images -f "dangling=true" -q);
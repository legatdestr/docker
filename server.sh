#!/usr/bin/env bash

CONTAINER_NAME='em_web_server';
CONTAINER_WORKDIR='/usr/local/apache2/htdocs/';
CONTAINER_HELP="Чтобы остановить контейнер, просто завершите сеанс работы в консоли. (Ctrl+D)";
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# stop container if it is exists
docker stop ${CONTAINER_NAME} 2>/dev/null;
echo "${CONTAINER_HELP}";
echo 'Запускаем контейнер: ' ${CONTAINER_NAME}.;


docker run -it --network="bridge" \
    --name ${CONTAINER_NAME} \
    -p 80:80 \
    --rm \
    -e "http_proxy=${http_proxy}" \
    -e "https_proxy=${http_proxy}" \
    -v ${SCRIPT_DIR}../../:/usr/share/nginx/html:ro \
    -w "${CONTAINER_WORKDIR}" \
    nginx ;
#!/usr/bin/env bash

CONTAINER_NAME='em_ksb_yo_app'
CONTAINER_WORKDIR='/app'
CONTAINER_HELP="Чтобы остановить контейнер, просто завершите сеанс работы в консоли. (Ctrl+D)"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# stop container if it is exists
docker stop ${CONTAINER_NAME} 2>/dev/null

echo "${CONTAINER_HELP}";
echo 'Запускаем контейнер: ' ${CONTAINER_NAME}.;

docker run -it --network="bridge" \
    -p9000:9000 \
    -p3001:3001 \
    --rm  \
    --name ${CONTAINER_NAME} \
    -e "http_proxy=${http_proxy}" \
    -e "https_proxy=${http_proxy}" \
    -v ${SCRIPT_DIR}../../:"${CONTAINER_WORKDIR}" \
    -w "${CONTAINER_WORKDIR}" \
    legatdestr/ksb-yo-webapp \
    /bin/bash ;


echo 'Выполнена команда запуска веб-сервера. В консоль будет выводиться лог запросов.';
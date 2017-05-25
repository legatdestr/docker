#!/usr/bin/env bash

CONTAINER_NAME='web_tablo';
CONTAINER_HELP="Чтобы остановить контейнер, просто завершите текущий процесс в консоли. (Ctrl+C, Ctrl+D)";
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR_NAME='container_tmp';
TMP_DIR=${SCRIPT_DIR}/"${TMP_DIR_NAME}";
LOGS_DIR=${TMP_DIR}/'logs';
HT_DOCS_DIR_PATH=${SCRIPT_DIR}/../htdocs;
PROTECTED_DIR_PATH=${SCRIPT_DIR}/../protected;
HT_TEMP_DIR_PATH=${SCRIPT_DIR}/../.ht_temp;

# stop container if it is exists
echo "Stopping container: ${CONTAINER_NAME}";
docker stop ${CONTAINER_NAME} 2>/dev/null;

echo "${CONTAINER_HELP}";
echo 'Запускаем контейнер: ' ${CONTAINER_NAME}.;

rm -rf ${TMP_DIR_NAME} 2>/dev/null;

mkdir ${TMP_DIR} && mkdir ${LOGS_DIR} 2>/dev/null;

chmod 777 ${HT_DOCS_DIR_PATH}/assets;
chmod 777 ${PROTECTED_DIR_PATH}/runtime;

docker run -d --network="bridge" \
    -p80:80 \
    --rm \
    --name ${CONTAINER_NAME} \
    -e http_proxy=${http_proxy} \
    -e https_proxy=${http_proxy} \
    -v ${HT_DOCS_DIR_PATH}:/var/www/vhosts/er.em70.ru/htdocs \
    -v ${PROTECTED_DIR_PATH}/../protected:/var/www/vhosts/er.em70.ru/protected \
    -v ${HT_TEMP_DIR_PATH}/../.ht_temp:/var/www/vhosts/er.em70.ru/.ht_temp \
    -v ${LOGS_DIR}:/var/www/vhosts/er.em70.ru/logs/ \
    legatdestr/ksb_web_tablo \
    apache2-foreground

docker exec -it ${CONTAINER_NAME} bash
docker stop ${CONTAINER_NAME} && echo "Container ${CONTAINER_NAME} was stopped."
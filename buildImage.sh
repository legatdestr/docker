#!/usr/bin/env bash

MAINTAINER='Kochetkov Sergey';

C_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
C_TMP_DIR=${C_SCRIPT_DIR}/'tmp';
C_YII1_ARCHIVE_FILEPATH=${C_TMP_DIR}/'yii1.tar.gz';
C_YII1_DOWNLOAD_PATH='https://github.com/yiisoft/yii/releases/download/1.1.18/yii-1.1.18.018a89.tar.gz';
C_YII1_UNPACKED_PATH=${C_TMP_DIR}/yii1;

C_DOCKER_IMAGE_NAME='ksb_web_tablo';

echo "Creating temporary directories: ${C_TMP_DIR}";
[ ! -d ${C_TMP_DIR} ] &&  mkdir ${C_TMP_DIR} ;
[ ! -d ${C_YII1_UNPACKED_PATH} ] && mkdir ${C_YII1_UNPACKED_PATH};

# downloading yiiframework v1:
curl -Lo ${C_YII1_ARCHIVE_FILEPATH} ${C_YII1_DOWNLOAD_PATH} && \
     tar -zxvf ${C_YII1_ARCHIVE_FILEPATH} -C ${C_YII1_UNPACKED_PATH} --strip-components=1

echo "Deleting old image (if exists): ${C_DOCKER_IMAGE_NAME}";
docker rmi ${C_DOCKER_IMAGE_NAME} 2>/dev/null;

#if [ $? -ne 0 ];  then
#      echo "Delete all docker containers, based on  ${C_DOCKER_IMAGE_NAME} image first!";
#      exit 1;
#fi;

docker build -t ${C_DOCKER_IMAGE_NAME} ${C_SCRIPT_DIR} \
       --build-arg http_proxy=${http_proxy} \
       --build-arg https_proxy=${http_proxy};

echo "Deleting temporary directory: ${C_TMP_DIR}";
rm -rf ${C_TMP_DIR} ;
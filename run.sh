#!/usr/bin/env bash

set -e
source .env

DOCKER_COMPOSE_FILE="docker-compose-dev.yml"

print_help() {
  echo "Работа с сервисом:"
  echo "для заполнения базы при выполните run.sh -D"
  echo
  echo "Использование: ./run.sh options..."
  echo "Параметры:"
  echo "    -h         Вызов справки"
  echo "    -s         Старт сервиса"
  echo "    -k         Остановка сервиса"
  echo "    -r         Очистка и удаление контейнеров и образов и данных БД. Требуется повышение прав"
  echo "    -d         Создание дампа базы (все в один файл, не рекомендуется использовать.) "
  echo "    -D         Восстановление базы из дампа (из одного файла. Не рекомендуется использовать)"
  echo "    -z         Создание дампа базы каждой таблицы в отдельности. Кладет в каталог separated. Предпочтительный способ. Внимание! Перед созданием, удаляет все sql файлы из separated!"
  echo "    -Z         Восстановление дампа базы каждой таблицы в отдельности из каталога separated. Предпочтительный способ."
  echo "    -e <имя контейнера>         Вход в контейнер"
  echo "    -p         Состояние сервисов"
  echo "    -l         Показать логи"

}

start_service() {
  echo "==========ВНИМАНИЕ========="
  echo "Если это первый запуск сервиса, или Dockerfile был отредактирован,"
  echo "или была проведена очистка и удаление образов"
  echo "контролируйте состояние запуска командой:"
  echo "docker-compose -f ${DOCKER_COMPOSE_FILE} logs -f"
  echo "После завершения развертывания можно выйти ctrl+c и продолжить работу"
  chmod 777 -R ${WEB_APP_DATA_DIR}
  docker-compose -f ${DOCKER_COMPOSE_FILE} up -d
}


show_logs() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} logs -f;
}

stop_service() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} stop
  docker-compose -f ${DOCKER_COMPOSE_FILE} rm -f
}


cleanup_files() {
  rm -rf $( ls ${DB_CONTAINER_DATA_DIR} | grep -v .gitkeep )  \
  && rm -rf $( ls ${PHPMYADMIN_CONTAINER_SESSIONS_DIR} | grep -v .gitkeep)
}

cleanup() {
  stop_service
  cleanup_files
  docker-compose -f ${DOCKER_COMPOSE_FILE} down --rmi all
}

exec_in_container() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} exec "$NAME" bash
}


create_dump() {
  docker exec ${DB_CONTAINER_NAME} sh -c   'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" ' > ${DB_DUMP_FILE_PATH}
}

restore_dump() {
  docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q ${DB_CONTAINER_NAME}) env MYSQL_PWD=${DB_PASS} mysql  -u ${DB_USER}  ${DB_NAME} < ${DB_DUMP_FILE_PATH};
}


create_dump2() {
    echo "Removing old dump files from ${DB_DUMP_PATH_SEPARATED}";
    rm -rf $( ls  ${DB_DUMP_PATH_SEPARATED} | grep -v .gitkeep )
    for T in `docker exec ${DB_CONTAINER_NAME}  env MYSQL_PWD=${DB_PASS} mysql -uroot  -N -B -e 'show tables from '${DB_NAME} ` ;
    do
        echo "dumping table structure for ${T}";
        docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q  ${DB_CONTAINER_NAME}) env MYSQL_PWD=${DB_PASS} mysqldump -u ${DB_USER} ${DB_NAME} --skip-comments --skip-dump-date --skip-set-charset --skip-tz-utc --no-data ${T} > ${DB_DUMP_PATH_SEPARATED}/${T}.sql
        if
            echo "dumping table data for      ${T}";
            docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q  ${DB_CONTAINER_NAME}) env MYSQL_PWD=${DB_PASS} mysqldump -u ${DB_USER} ${DB_NAME} --skip-comments --skip-dump-date --skip-set-charset --skip-tz-utc --no-create-info ${T} > ${DB_DUMP_PATH_SEPARATED}/${T}.data
        fi
    done;
}

restore_dump2() {
   echo 'MySQL: starting to restore separated sql files from '${DB_DUMP_PATH_SEPARATED};
   cat $( ls -rtd  ${DB_DUMP_PATH_SEPARATED}/*.sql  ) | docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q  ${DB_CONTAINER_NAME})  bash -c "env MYSQL_PWD=${DB_PASS} mysql -u${DB_USER}  ${DB_NAME} "
   echo 'MySQL: starting to restore data sql files from '${DB_DUMP_PATH_SEPARATED};
   cat $( ls -rtd  ${DB_DUMP_PATH_SEPARATED}/*.data  ) | docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q  ${DB_CONTAINER_NAME})  bash -c "env MYSQL_PWD=${DB_PASS} mysql -u${DB_USER}  ${DB_NAME} "
}



state() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} ps
}


if [ $# = 0 ]; then
    print_help
fi

while getopts ":hskrdDzZle:p" opt;
do
  case $opt in
	h) print_help
	;;
	s) start_service
	;;
	k) stop_service
	;;
	r) cleanup
	;;
	d) create_dump
	;;
	D) restore_dump
	;;
	e) NAME=$OPTARG;
	   exec_in_container
	;;
	z) create_dump2
	;;
	Z) restore_dump2
	;;
	l) show_logs
	;;
	p) state
	;;
	*) echo 'Wrong key! Run "run.sh -h" for help'
	  exit 1
	;;
  esac
done
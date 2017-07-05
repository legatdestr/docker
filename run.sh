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
  echo "    -p         Показать логи"

}

start_service() {
  echo "==========ВНИМАНИЕ========="
  echo "Если это первый запуск сервиса, или Dockerfile был отредактирован,"
  echo "или была проведена очистка и удаление образов"
  echo "контролируйте состояние запуска командой:"
  echo "docker-compose -f ${DOCKER_COMPOSE_FILE} logs -f"
  echo "После завершения развертывания можно выйти ctrl+c и продолжить работу"
  docker-compose -f ${DOCKER_COMPOSE_FILE} up -d
}


show_logs() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} logs -f;
}

stop_service() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} stop
}


cleanup() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} down --rmi all && rm -rf ${DB_CONTAINER_DATA_DIR} \
  && rm -rf ${PHPMYADMIN_CONTAINER_SESSIONS_DIR}
}

exec_in_container() {
  docker-compose -f ${DOCKER_COMPOSE_FILE} exec "$NAME" bash
}


create_dump() {
  docker exec ${DB_CONTAINER_NAME} sh -c   'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > ${DB_DUMP_FILE_PATH}
}

restore_dump() {
  docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q ${DB_CONTAINER_NAME}) env MYSQL_PWD=${DB_PASS} mysql  -u ${DB_USER}  ${DB_NAME} < ${DB_DUMP_FILE_PATH};
}


create_dump2() {
    echo "Removing old dump files from ${DB_DUMP_PATH_SEPARATED}";
    rm -rf ${DB_DUMP_PATH_SEPARATED}/*.sql;
    for T in `docker exec ${DB_CONTAINER_NAME}  mysql -uroot --password=${DB_ROOT_PASS} -N -B -e 'show tables from '${DB_NAME} ` ;
    do
        echo "dumping table ${T}";
        docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q  ${DB_CONTAINER_NAME}) env MYSQL_PWD=${DB_PASS} mysqldump -u ${DB_USER} ${DB_NAME} ${T} > ${DB_DUMP_PATH_SEPARATED}/${T}.sql
    done;
}

restore_dump2() {
   echo 'starting to restore separated files';
   cat $( ls -rtd  ${DB_DUMP_PATH_SEPARATED}/*.sql  ) | docker exec -i $(docker-compose -f ${DOCKER_COMPOSE_FILE} ps -q  ${DB_CONTAINER_NAME})  bash -c "env MYSQL_PWD=${DB_PASS} mysql -u${DB_USER}  ${DB_NAME} "
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
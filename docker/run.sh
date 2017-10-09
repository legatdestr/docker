#!/bin/bash

set -e
source .env

print_help() {
  echo "Работа с сервисом:"
  echo "для заполнения базы при выполните run.sh -D"
  echo 
  echo "Использование: ./run.sh options..."
  echo "Параметры:"
  echo "    -h         Вызов справки"
  echo "    -s         Старт сервиса"
  echo "    -k         Остановка сервиса"
  echo "    -r         Очистка и удаление контейнеров и образов и данных БД. Требуется повышения прав"
  echo "    -R         Очистка и удаление контейнеров и данных БД. Требуется повышения прав"
  echo "    -d         Создание дампа базы"
  echo "    -D         Восстановление базы из дампа "
  echo "    -e <имя контейнера>         Вход в контейнер"
  echo "    -p         Состояние сервисов"
	
}

start_service() {
  echo "==========ВНИМАНИЕ========="
  echo "Если это первый запуск сервиса, или Dockerfile был отредактирован,"
  echo "или была проведена очистка и удаление образов"
  echo "контролируйте состояние запуска командой:"
  echo "docker-compose logs -f"
  echo "После завершения развертывания можно выйти ctrl+c и продолжить работу"
  echo "Включите debugger в своей IDE. remote_port=9001"
  docker-compose up -d
}

stop_service() {
  docker-compose stop
}

cleanup() {
  docker-compose down --rmi all && rm -rf ${DB_CONTAINER_DATA_DIR}9.6
}

cleanup_local() {
  docker-compose down --rmi local && rm -rf ${DB_CONTAINER_DATA_DIR}9.6
}

exec_in_container() {
  docker-compose exec "$NAME" bash
}

create_dump() {
  docker-compose exec postgresql pg_dump  -U ${DB_USER} -w   -d ${DB_NAME} > $DUMP_DIR/sqldump.sql
}

restore_dump() {
  docker exec -i $(docker-compose ps -q postgresql) psql  -U ${DB_USER} -w -d ${DB_NAME} < $DUMP_DIR/sqldump.sql
}	

state() {
  docker-compose ps
}


if [ $# = 0 ]; then
    print_help
fi


while getopts ":hskrRdDe:p" opt;
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
	R) cleanup_local
	;;
	d) create_dump
	;;
	D) restore_dump
	;;
	e) NAME=$OPTARG;
	   exec_in_container
	;;
	p) state
	;;
	*) echo 'Wrong key! Run "run.sh -h" for help'
	  exit 1
	;;
  esac
done
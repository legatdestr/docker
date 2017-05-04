# docker

Docker. Установка.

Docker. Настройка для работы.

1) Важно задать правильный DNS сервер. Для этого положить json файл "daemon.json" настроек сюда: /etc/docker/
либо запускате docker клиент с пар-ом: --config-file daemon.json
Пример настроек:

`{
    "dns": ["10.10.10.1"],
    "ipv6": false,
    "ip-forward": true,
    "selinux-enabled": false
}`

Полное описание всех настроек смотри здесь:
https://docs.docker.com/engine/reference/commandline/dockerd//

2) перезапустить демон докер:
sudo service docker restart

3) для включения ПРОКСИ включите его здесь:
/etc/default/docker
а вот адрес dns сервера в этом файле не задается (не работает, хотя настройка есть)
# docker

## Docker. Установка. (Для Ubuntu).

1) Установить пакеты через apt для использования поверх HTTPS:

`sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common`

2) Добавить официальный GPG ключ Docker'а:

`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

3) Используя следующую команду, загрузить стабильный репозиторий:

Примечание: подкоманда `lsb_release -cs` возвращает имя Ubuntu дистрибутива, например `xenial`.
Иногда, в дистрибутивах типа Linux Mint, нужно изменить `$(lsb_release -cs)` на имя родительского
дистрибутива Ubuntu. Например, для Linux Mint Rafaela, нужно прописать trusty.

для amd64:

`sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"`

для armhf:

`sudo add-apt-repository \
   "deb [arch=armhf] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"`

4) Установка непосредственно Docker CE:

`sudo apt-get update`
`sudo apt-get install docker-ce`

5) Использование Docker без прав root (опционально):

`sudo groupadd docker` - создание группы docker
`sudo usermod -aG docker $USER` - добавление текущего пользователя в группу docker

## Docker. Настройка для работы c прокси:

### Настроить Docker для загрузки из сети нужных ему пакетов:

#### Для Ubuntu 14.04 LTS

Ubuntu 14.04 использует SysVinit, поэтому нужно:

1) модифицировать файл /etc/default/docker:

`
export http_proxy="http://web-proxy.corp.xxxxxx.com:8080/"
export https_proxy="https://web-proxy.corp.xxxxxx.com:8080/"`

2) Перезапустить docker:

`sudo service docker restart`

#### Для Ubuntu 16.04 LTS

Ubuntu 16.04 использует Systemd, поэтому нужно:

1) Создать директорию:

`mkdir /etc/systemd/system/docker.service.d`

2) Добавить настройки прокси в файл
`/etc/systemd/system/docker.service.d/http-proxy.conf`:

`
[Service]
Environment="HTTP_PROXY=https://proxy:6666"
Environment="HTTPS_PROXY=https://proxy:6666"`

### Настроить Docker для доступа к сети из контейнера через прокси:

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

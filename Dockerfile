FROM node:7
LABEL maintainer Sergey Kocketkov <legatdestr@gmail.com>
ENV KSB_JS_VERSION 0.0.1

RUN mkdir /app
WORKDIR /app
RUN npm install --global gulp

# Example of building image:
# docker build -t ksb-js `pwd` --build-arg https_proxy=${http_proxy} --build-arg http_proxy=${http_proxy}
# Пример запуска:
# docker run -d -p 80:80 -v `pwd`/htdocs:/var/www/vhosts/infotouch.em70.ru/htdocs/ ksb-js

FROM legatdestr/ksb-js
LABEL maintainer Sergey Kocketkov <legatdestr@gmail.com>
ENV KSB_JS_VERSION 0.0.2

WORKDIR /app
RUN npm install -g yo bower grunt-cli gulp generator-webapp && npm cache clear
RUN mkdir -p /root/.config/configstore && chmod g+rwx -R /root /root/.config /root/.config/configstore /
    chown -R root /usr/local/lib/node_modules/

# Example of building image:
# docker build -t ksb-yo-webapp `pwd` --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${http_proxy}
FROM legatdestr/ksb-js
LABEL maintainer Sergey Kocketkov <legatdestr@gmail.com>
ENV KSB_JS_VERSION 0.0.2

WORKDIR /app

RUN npm install --global yo  && npm cache clear && \
    npm install --global gulp-cli  && npm cache clear && \
    npm install --global bower && npm cache clear && \
    npm install --global generator-webapp && npm cache clear  && \
    echo '{ "allow_root": true }' > /root/.bowerrc

RUN mkdir -p /root/.config/configstore && chmod g+rwx -R /root /root/.config /root/.config/configstore && \
    chown -R root /usr/local/lib/node_modules/


# Define default command.
CMD ["bash"]

# Example of building image:
# docker build -t ksb-yo-webapp `pwd` --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${http_proxy}
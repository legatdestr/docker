
# pull base image
FROM ubuntu:16.04
LABEL maintainer Sergey Kocketkov <legatdestr@gmail.com>



# Install updates, get packages
RUN apt-get update --fix-missing -y -qq
RUN apt-get install sudo
RUN sudo apt-get install -y build-essential libssl-dev curl wget software-properties-common


RUN sudo apt-get install -y git git-core

RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Install yeoman, generators and dependencies
RUN sudo npm install -g grunt-cli bower harp@next gulpjs/gulp-cli yo typings generator-karma generator-angular generator-webapp generator-fountain-webapp foundation-cli

RUN sudo npm install -g generator-babel-boilerplate

RUN sudo npm install -g generator-react-fullstack

# Install nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 7

#RUN wget -qO- https://raw.githubusercontent.com/xtuple/nvm/master/install.sh | sudo bash \
#    && source $NVM_DIR/nvm.sh \
#    && nvm install $NODE_VERSION \
#    && nvm alias default $NODE_VERSION \
#    && nvm use default

RUN    echo '{ "allow_root": true }' > /root/.bowerrc

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH



# Add a yeoman user because grunt doesn't like being root
RUN adduser --disabled-password --gecos "" yeoman; \
  echo "yeoman ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER yeoman


# Create a directory for the app
RUN sudo mkdir -p /app && cd $_
WORKDIR /app

EXPOSE 9000

CMD ["bash"]

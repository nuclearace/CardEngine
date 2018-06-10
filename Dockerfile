FROM swiftdocker/swift
RUN apt-get update && apt-get install -y wget

# Install node.js
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.4.0

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
# End node.js

# Install vapor
RUN /bin/bash -c "$(wget -qO- https://apt.vapor.sh)"
RUN apt-get install vapor -y

# Start building the app

WORKDIR /usr/src/app
COPY . /usr/src/app

# TODO configure debug build vs release
RUN npm install
RUN npm run build
RUN swift build

ENV PATH ./.build/x86_64-unknown-linux/debug:$PATH

EXPOSE 8080

CMD ./.build/x86_64-unknown-linux/debug/Server --hostname 0.0.0.0

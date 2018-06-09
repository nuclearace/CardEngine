FROM swiftdocker/swift
RUN apt-get update && apt-get install -y wget
RUN /bin/bash -c "$(wget -qO- https://apt.vapor.sh)"
RUN apt-get install vapor -y

WORKDIR /usr/src/app
COPY . /usr/src/app

# TODO configure debug build vs release
RUN swift build

ENV PATH ./.build/x86_64-unknown-linux/debug:$PATH

EXPOSE 8080

CMD ./.build/x86_64-unknown-linux/debug/Server --hostname 0.0.0.0

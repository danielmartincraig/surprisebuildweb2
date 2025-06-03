# syntax = docker/dockerfile:1.2
FROM clojure:temurin-21-bookworm AS build
ARG NODE_VERSION=20

WORKDIR /usr/app
COPY ./ /usr/app

RUN apt update && apt install curl -y

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

ENV NVM_DIR=/root/.nvm

RUN bash -c "source $NVM_DIR/nvm.sh && npm i -g npm && nvm install $NODE_VERSION"

RUN bash -c "source $NVM_DIR/nvm.sh && npm install"

RUN bash -c "source $NVM_DIR/nvm.sh && clj -Sforce -T:build all"

FROM azul/zulu-openjdk-alpine:21

COPY --from=build /target/surprisebuildweb2-standalone.jar /surprisebuildweb2/surprisebuildweb2-standalone.jar

EXPOSE $PORT

ENTRYPOINT exec java $JAVA_OPTS -jar /surprisebuildweb2/surprisebuildweb2-standalone.jar
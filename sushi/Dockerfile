FROM node:lts-alpine

USER root

RUN npm install -g fsh-sushi

WORKDIR /IG

CMD rm -rf fsh-generated && \
    rm -rf input && \
    mkdir -p input/fsh && \
    cp /src/fsh/*.* input/fsh && \
    sushi .

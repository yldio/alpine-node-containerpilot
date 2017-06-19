FROM node:7.10.0-alpine

# Get and configure containerpilot
ENV CP_SHA1 6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c
ENV CONTAINERPILOT_VERSION 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json

RUN set -x \
    && apk update \
    && apk add --update curl bash git make \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && yarn --version \
    && mkdir -p /home/node/app/ \
    && curl -Lo /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz

ENV BUILD=production
ENV NODE_ENV=production

RUN mkdir -p /opt/app/
ONBUILD COPY . /opt/app/
ONBUILD WORKDIR /opt/app/

ONBUILD CMD ["/bin/containerpilot"]

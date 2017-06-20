FROM node:8-alpine

# Get and configure containerpilot
ENV CP_SHA1 6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c
ENV CONTAINERPILOT_VERSION 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json
ENV CONSUL_VERSION 0.7.0
ENV CONSUL_CHECKSUM b350591af10d7d23514ebaa0565638539900cdb3aaa048f077217c4c46653dd8

# install dependencies
RUN set -x \
 && apk update \
 && apk add --update curl bash git make \
 && apk upgrade \
 && rm -rf /var/cache/apk/* \
 && yarn --version

# install consul agent
RUN curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
 && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
 && unzip /tmp/consul -d /usr/local/bin \
 && rm /tmp/consul.zip \
 && mkdir /config

# install container pilot
RUN curl -Lo /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
 && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
 && tar zxf /tmp/containerpilot.tar.gz -C /bin \
 && rm /tmp/containerpilot.tar.gz

ENV BUILD=production
ENV NODE_ENV=production

RUN mkdir -p /opt/app/
ONBUILD COPY . /opt/app/
ONBUILD WORKDIR /opt/app/

ONBUILD CMD ["/bin/containerpilot"]

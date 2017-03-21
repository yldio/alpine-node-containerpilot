FROM node:7.7.3-alpine

# Get and configure containerpilot
ENV CONTAINERPILOT_VERSION 2.7.0
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN set -x \
    && apk update \
    && apk add --update curl bash git make \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && yarn --version \ # assert that yarn is installed
    && mkdir -p /home/node/app/ \
    && export CP_SHA1=687f7d83e031be7f497ffa94b234251270aee75b \
    && curl -Lo /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz

ENV BUILD=production
ENV NODE_ENV=production

COPY ./sensors.sh /bin/sensors

ONBUILD COPY ./etc/containerpilot.json /etc/

ONBUILD COPY . /home/node/app/
# Because copy / add, adds files as root.
ONBUILD RUN chown -R node:node /home/node/
ONBUILD USER node
ONBUILD WORKDIR /home/node/app/
ONBUILD RUN make install-production

ONBUILD CMD [ "/bin/containerpilot", "make", "start" ]

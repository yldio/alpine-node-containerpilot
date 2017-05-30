FROM node:7.10.0-alpine

# Get and configure containerpilot
ENV CONTAINERPILOT_VERSION 2.7.3
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN set -x \
    && apk update \
    && apk add --update curl bash git make \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && yarn --version \
    && mkdir -p /home/node/app/ \
    && export CP_SHA1=2511fdfed9c6826481a9048e8d34158e1d7728bf \
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

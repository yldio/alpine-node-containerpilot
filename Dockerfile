FROM node:6.9.4-alpine

# Get and configure containerpilot
ENV CONTAINERPILOT_VERSION 2.6.0
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN set -x \
    && apk update \
    && apk add --update curl bash git make \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && npm install --quiet --no-spin --global yarn@0.19.1 \
    && mkdir -p /home/node/app/ \
    && export CP_SHA1=c1bcd137fadd26ca2998eec192d04c08f62beb1f \
    && curl -Lo /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz

ENV BUILD=production
ENV NODE_ENV=production

ONBUILD COPY ./etc/containerpilot.json /etc/

ONBUILD COPY . /home/node/app/
# Because copy / add, adds files as root.
ONBUILD RUN chown -R node:node /home/node/
ONBUILD USER node
ONBUILD WORKDIR /home/node/app/
ONBUILD RUN make install-production

ONBUILD CMD [ "/bin/containerpilot", "make", "start" ]

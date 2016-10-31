FROM mhart/alpine-node:6.9.1

# Get and configure containerpilot
ENV CONTAINERPILOT_VERSION 2.4.3
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN set -x \
    && apk update \
    && apk add --update curl bash git make \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && npm install --quiet --no-spin --global yarn@0.16.1 \
    && adduser -u 431 -D -h /home/nodejs -s '/sbin/nologin -c "Docker image user"' nodejs \
    && mkdir -p /home/nodejs/app/ \
    && export CP_SHA1=2c469a0e79a7ac801f1c032c2515dd0278134790 \
    && curl -Lo /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz

ONBUILD COPY ./etc/containerpilot.json /etc/

ONBUILD COPY . /home/nodejs/app/
# Because copy / add, adds files as root.
ONBUILD RUN chown -R nodejs:nodejs /home/nodejs/
ONBUILD USER nodejs
ONBUILD WORKDIR /home/nodejs/app/
ONBUILD RUN make install-production

ONBUILD CMD [ "/bin/containerpilot", "make", "start" ]

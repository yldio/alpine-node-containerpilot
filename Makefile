.PHONY: build
build:
	docker build -t quay.io/yldio/alpine-node-containerpilot:latest \
                -t quay.io/yldio/alpine-node-containerpilot:7.7.3 \
                -t quay.io/yldio/alpine-node-containerpilot:7.7 \
                -t quay.io/yldio/alpine-node-containerpilot:7 .

.PHONY: push
push:
	docker push quay.io/yldio/alpine-node-containerpilot

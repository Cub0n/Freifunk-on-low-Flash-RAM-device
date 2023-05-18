#!/bin/sh

docker run -it \
	-e TZ=Europe/Berlin \
	-v /path/to/gluon:/gluon \
	--no-healthcheck=true \
    --pull=newer \
	builder

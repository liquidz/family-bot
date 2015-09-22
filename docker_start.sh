#!/bin/sh

export Redis_url="redis://$REDIS_PORT_6379_TCP_ADDR:$REDIS_PORT_6379_TCP_PORT"

mix start

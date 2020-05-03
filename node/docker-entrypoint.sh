#!/bin/sh

CONFIG_FILE="/usr/local/etc/redis/redis.conf"
echo "port ${REDIS_PORT}" >> "${CONFIG_FILE}"

cat "${CONFIG_FILE}"
redis-server "${CONFIG_FILE}"

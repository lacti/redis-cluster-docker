FROM redis

COPY redis.conf /usr/local/etc/redis/redis.conf
COPY docker-entrypoint.sh /

ENV REDIS_PORT 6379

CMD /bin/bash /docker-entrypoint.sh

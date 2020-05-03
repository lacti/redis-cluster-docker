FROM redis

RUN apt-get update && \
  apt-get install -y dnsutils netcat

# Setup waiter
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait
RUN chmod +x /wait

COPY docker-entrypoint.sh /
ENV CLUSTER_SPEC ""

CMD /bin/bash /docker-entrypoint.sh

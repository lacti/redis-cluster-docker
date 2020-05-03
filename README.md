# Redis Cluster in Docker compose

A simple example to run Redis Cluster using docker-compose.

## Quick start

```bash
docker-compose build && \
  docker-compose up
```

It will build a cluster with 3 Redis nodes.

## [Redis cluster node](node)

Actually, it can use the same port across all cluster nodes but in many other examples, each of cluster node would have a difference port such as 7000, 7001 and 7002.

`redis-cluster-node` docker is almost same with `redis:latest` docker only except its port number.

## [Redis cluster builder](builder)

After all cluster nodes wake up, it should execute a command to create a cluster. So it [waits](https://github.com/ufoscout/docker-compose-wait) all nodes wake up, and execute `redis-cli --cluster create` with their hosts and ports.

But `redis-cli --cluster create` requires resolved ip address instead of `hostname` such as `redis-1`. So before executing a command, resolves their hostnames as actual ip address using `dig` command.

## Drawback

This example doesn't use fixed ip addresses due to reduce complexity of docker definition. But because of this, this cluster can be break after these docker instance are restarted and lost their ip address.

To resolve this problem, [other example](https://github.com/cpapidas/docker-compose-redis-cluster/) gives fixed ip addresses to Redis cluster nodes using [`networks.app_net.ipv4_address`](https://docs.docker.com/compose/compose-file/#ipv4_address-ipv6_address).

## License

MIT

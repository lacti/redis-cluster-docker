#!/bin/bash

set -ux

if [ -z "${CLUSTER_SPEC:-""}" ]; then
  echo "Please set CLUSTER_SPEC environment variable."
  echo "eg) CLUSTER_SPEC=\"host1:port1[, host2:post2, ...]\""
  exit 0
fi

# Wait other hosts.
if [ -z "${WAIT_HOSTS:-""}" ]; then
  export WAIT_HOSTS="${CLUSTER_SPEC}"
  /wait
  if [ $? -ne 0 ]; then
    echo "Cannot wait other hosts: ${WAIT_HOSTS}"
    exit 1
  fi
fi

# Resolve cluster spec.
MASTER_HOST=""
MASTER_PORT=""
RESOLVED=""
PAIRS=($(echo "${CLUSTER_SPEC}" | tr -d " " | tr "," '\n'))
for PAIR in "${PAIRS[@]}"; do
  HOST="$(echo "${PAIR}" | cut -d ":" -f1)"
  PORT="$(echo "${PAIR}" | cut -d ":" -f2)"
  if [ -z "${MASTER_HOST}" ]; then
    MASTER_HOST="${HOST}"
    MASTER_PORT="${PORT}"
  fi
  HOST_IP="$(dig "${HOST}" +short)"
  if [ ! -z "${HOST_IP}" ]; then
    RESOLVED="${RESOLVED} ${HOST_IP}:${PORT}"
  fi
done

if [ -z "${MASTER_HOST}" ] || [ -z "${MASTER_PORT}" ]; then
  echo "Invalid CLUSTER_SPEC: ${CLUSTER_SPEC}"
  exit 1
fi

# Check if the cluster is already set.
CLUSTER_COMMAND="CLUSTER INFO"
if [ ! -z "${MASTER_PASSWORD:-""}" ]; then
  CLUSTER_COMMAND="AUTH ${MASTER_PASSWORD}\nCLUSTER INFO"
fi

CLUSTER_INFO="$(echo -e "${CLUSTER_COMMAND}" | nc -q1 "${MASTER_HOST}" "${MASTER_PORT}")"
# echo "${CLUSTER_INFO}" | grep "This instance has cluster support disabled"
echo "${CLUSTER_INFO}" | grep "cluster_state:ok"
if [ $? -eq 0 ]; then
  echo "Cluster is already set."
  echo "${CLUSTER_INFO}"
  exit 0
fi

# Make the cluster.
echo "MASTER_PORT=${MASTER_PORT}"
echo "CLUSTER=${RESOLVED}"
redis-cli -p ${MASTER_PORT} --cluster create${RESOLVED} --cluster-yes

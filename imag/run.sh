#!/bin/bash

# Copyright 2014 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function launchmaster() {
  if [[ ! -e /redis-master-data ]]; then
    echo "Redis master data doesn't exist, data won't be persistent!"
    mkdir /redis-master-data
  fi
  awk -v my_var=$REDISPASS '{ sub(/%redis-pass%/, my_var); print }' /redis-master/redis.tmp > /redis-master/redis.conf
  if [ $? -ne 0 ]; then
    echo "set redis password failed!"
    exit 1
  fi
  redis-server /redis-master/redis.conf
}

function launchsentinel() {
  while true; do
    master=$(redis-cli -a $REDISPASS -h ${REDIS_SENTINEL_SERVICE_HOST} -p ${REDIS_SENTINEL_SERVICE_PORT} --csv SENTINEL get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1)
    if [[ -n ${master} ]]; then
      master="${master//\"}"
    else
      master=${REDIS_MASTER_SERVICE_HOST}
    fi

    redis-cli -a $REDISPASS -h ${master} INFO
    if [[ "$?" == "0" ]]; then
      break
    fi
    echo "Connecting to master failed.  Waiting..."
    sleep 10
  done

  sentinel_conf=sentinel.conf

  echo "sentinel monitor mymaster ${master} 6379 2" > ${sentinel_conf}
  echo "sentinel auth-pass mymaster ${REDISPASS}" >> ${sentinel_conf}
  echo "sentinel down-after-milliseconds mymaster 60000" >> ${sentinel_conf}
  echo "sentinel failover-timeout mymaster 180000" >> ${sentinel_conf}
  echo "sentinel parallel-syncs mymaster 1" >> ${sentinel_conf}
  echo "bind 0.0.0.0" >> ${sentinel_conf}

  redis-sentinel ${sentinel_conf} --protected-mode no
}

function launchslave() {
  awk -v my_var=$MASTERSVC '{ sub(/%master-ip%/, my_var); print }' /redis-slave/redis.tmp > /redis-slave/redis.conf
  awk -v my_var=$REDISPASS '{ sub(/%redis-pass%/, my_var); print }' /redis-slave/redis.tmp > /redis-slave/redis.conf
  redis-server /redis-slave/redis.conf --protected-mode no
}

if [[ "${MASTER}" == "true" ]]; then
  launchmaster
  exit 0
fi

if [[ "${SENTINEL}" == "true" ]]; then
  launchsentinel
  exit 0
fi

launchslave

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
  if [[ ! -e /redis/master-data ]]; then
    echo "Redis master data doesn't exist, data won't be persistent!"
    mkdir -p /redis/master-data
  fi
  awk -v my_var=$REDISPASS '{ sub(/%redis-pass%/, my_var); print }' /redis/master-config/redis.tmp > /redis/master-config/redis.conf
  if [ $? -ne 0 ]; then
    echo "set redis password failed!"
    exit 1
  fi
  redis-server /redis/master-config/redis.conf
}

function launchslave() {
  awk -v master=$MASTERSVC -v passwd=$REDISPASS '{ sub(/%master-ip%/, master); sub(/%redis-pass%/, passwd); print }' /redis/slave-config/redis.tmp > /redis/slave-config/redis.conf
  redis-server /redis/slave-config/redis.conf
}

if [[ "${MASTER}" == "true" ]]; then
  launchmaster
  exit 0
fi

launchslave

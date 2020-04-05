#! /bin/bash

# Copyright 2016 The Kubernetes Authors.
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

# This script writes out a mysql galera config using a list of newline seperated
# peer DNS names it accepts through stdin.

# /etc/mysql is assumed to be a shared volume so we can modify my.cnf as required
# to keep the config up to date, without wrapping mysqld in a custom pid1.
# The config location is intentionally not /etc/mysql/my.cnf because the
# standard base image clobbers that location.

set -o errexit
set -o xtrace

function join {
    local IFS="$1"; shift; echo "$*";
}

NODE_IP=$(hostname -I | awk ' { print $1 } ')
CLUSTER_NAME="$(hostname -f | cut -d'.' -f2)"
SERVER_ID=${HOSTNAME/$CLUSTER_NAME-}

while read -ra LINE; do
    echo "read line $LINE"
    LINE_IP=$(getent hosts "$LINE" | awk '{ print $1 }')
    if [ "$LINE_IP" != "$NODE_IP" ]; then
        PEERS=("${PEERS[@]}" $LINE_IP)
    fi
done

if [ "${#PEERS[@]}" != 0 ]; then
    $(MEMBERS_OF_CLUSTER=$(join , "${PEERS[@]}")) >> /etc/mongo.d/members
fi
i=0
for peer in $PEERS[@]
do
   cat <<-EOF >> /etc/mongo.d/members.conf

      {
         "_id" : $i,
         "host" : "$peer:27017",
         "arbiterOnly" : false,
         "buildIndexes" : true,
         "hidden" : false,
         "priority" : 1,
         "tags" : {

         },
         "slaveDelay" : NumberLong(0),
         "votes" : 1
      },
EOF
i=i+1

done


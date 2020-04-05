#!/bin/bash

peer-list --on-start=./mongo-configure.sh --service='${MONGO_SERVICE}'


exec "mongod"
#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

GCC_INSTALL=$(cat $JSON_CONFIG | jq -r ".GCC_INSTALL")

export LD_LIBRARY_PATH=/home/ssm-user/gcc_build/install/lib64:$LD_LIBRARY_PATH


#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
PROJECT=$(cat $JSON_CONFIG | jq -r ".PROJECT")
export DCPERF_PERF_RECORD=1

ulimit -n 100000
sysctl -w net.ipv4.ip_local_port_range='1024 65535'

source $PY_ENV/bin/activate
cd $DCPERF_DIR
$PY_ENV/bin/python3 ./benchpress_cli.py run $PROJECT -i '{"clients_per_thread": 75}'

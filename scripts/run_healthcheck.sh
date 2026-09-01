#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
PROJECT=$(cat $JSON_CONFIG | jq -r ".PROJECT")
export DCPERF_PERF_RECORD=1

. $PY_ENV/bin/activate
cd $DCPERF_DIR

$PY_ENV/bin/python3 ./benchpress_cli.py run health_check -r client &
$PY_ENV/bin/python3 ./benchpress_cli.py run health_check -r server -i "{\"clients\": \"$(hostname -I)\"}" &

wait


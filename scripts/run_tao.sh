#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

RUNS_DIR=$SCRIPT_DIR/../runs
mkdir -p $RUNS_DIR

PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
PROJECT=$(cat $JSON_CONFIG | jq -r ".PROJECT")
export DCPERF_PERF_RECORD=1

ulimit -n 100000
sysctl -w net.ipv4.ip_local_port_range='1024 65535'
lsof -t -i tcp:11211 | xargs kill
lsof -t -i tcp:11212 | xargs kill

source $PY_ENV/bin/activate
cd $DCPERF_DIR

RUN_TIMESTAMP=$(date +%s)
RUN_DIR=$RUNS_DIR/run_$RUN_TIMESTAMP
mkdir -p $RUN_DIR

RESULTS_DIR=$RUN_DIR/results
ARTIFACTS_DIR=$RUN_DIR/artifacts
LOG_FILE=$RUN_DIR/run_cmd.log

mkdir -p $RESULTS_DIR
mkdir -p $ARTIFACTS_DIR

echo Writing to $LOG_FILE

$PY_ENV/bin/python3 ./benchpress_cli.py -t $RUN_TIMESTAMP --results $RESULTS_DIR \
	--artifacts-dir $ARTIFACTS_DIR run -i '{"auto_fix_ports":1,"auto_fix_ulimit":1}' \
	$PROJECT 2>&1 | tee $LOG_FILE

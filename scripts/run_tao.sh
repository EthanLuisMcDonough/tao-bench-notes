#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

echo $JSON_CONFIG

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

TOOLCHAIN=$1
RUN_DIR=$2
RUNS_DIR=$SCRIPT_DIR/../runs
mkdir -p $RUNS_DIR

PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
PROJECT=$(cat $JSON_CONFIG | jq -r ".PROJECT")
RUN_CONFIG=$(cat $JSON_CONFIG | jq -r ".CONFIGS.$PROJECT // {} | tostring")

case $TOOLCHAIN in
    clang)
        source $SCRIPT_DIR/init_llvm_run_env.sh
        ;;
    gcc)
        source $SCRIPT_DIR/init_gcc_run_env.sh
        ;;
    *)
        echo "Bad toolchain"
        exit 1
        ;;
esac

ulimit -n 100000
sysctl -w net.ipv4.ip_local_port_range='1024 65535'
lsof -t -i tcp:11211 | xargs kill
lsof -t -i tcp:11212 | xargs kill

source $PY_ENV/bin/activate

RUN_TIMESTAMP=$(date +%s)
if [[ -z $RUN_DIR ]]; then
    RUN_DIR=$RUNS_DIR/$PROJECT/run_$RUN_TIMESTAMP
else
    RUN_DIR=$(realpath $RUN_DIR)
fi
mkdir -p $RUN_DIR

cd $DCPERF_DIR

RESULTS_DIR=$RUN_DIR/results
ARTIFACTS_DIR=$RUN_DIR/artifacts
LOG_FILE=$RUN_DIR/run_cmd.log
PERF_DIR=$RUN_DIR/perflogs

mkdir -p $RESULTS_DIR
mkdir -p $ARTIFACTS_DIR
mkdir -p $PERF_DIR

echo LD_LIBRARY_PATH $LD_LIBRARY_PATH

echo Writing to $LOG_FILE
$PY_ENV/bin/python3 ./benchpress_cli.py -t $RUN_TIMESTAMP --results $RESULTS_DIR \
	--artifacts-dir $ARTIFACTS_DIR run -i $RUN_CONFIG $PROJECT 2>&1 | tee $LOG_FILE & \
	$SCRIPT_DIR/take_snapshot.sh $PERF_DIR & wait

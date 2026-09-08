#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json
DIRECTORY=$1

echo PERF OUTPUT AT $DIRECTORY

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

SNAPSHOT_SLEEP=$(cat $JSON_CONFIG | jq -r ".SNAPSHOT_SLEEP")
SNAPSHOT_LEN=$(cat $JSON_CONFIG | jq -r ".SNAPSHOT_LEN // 15")

if [[ -z "$DIRECTORY" ]]; then
    exit 0;
fi

if [ "$SNAPSHOT_SLEEP" = "null" ]; then
    exit 0;
fi

echo RECORDING TAO EVERY $SNAPSHOT_SLEEP s for $SNAPSHOT_LEN s

set -e

while true; do
    sleep $SNAPSHOT_SLEEP
    echo "RUNNING PERF"
    $SCRIPT_DIR/take_snapshot.sh $DIRECTORY $SNAPSHOT_LEN
done


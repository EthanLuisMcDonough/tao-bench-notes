#!/bin/sh

SCRIPT_DIR=$( dirname -- $0 )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
$PY_ENV/bin/python3 ./benchpress_cli.py clean tao_bench_standalone

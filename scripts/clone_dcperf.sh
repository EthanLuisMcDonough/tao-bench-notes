#!/bin/sh

SCRIPT_DIR=$( dirname -- $0 )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
DCPERF_FOLDER_NAME=$(basename $DCPERF_DIR)
DCPERF_FOLDER_PATH=$(dirname $DCPERF_DIR)

mkdir -p $DCPERF_FOLDER_PATH
cd $DCPERF_FOLDER_PATH

if [ ! -f $DCPERF_FOLDER_NAME ]; then
    git clone https://github.com/EthanLuisMcDonough/DCPerf $DCPERF_FOLDER_NAME
fi

cd $DCPERF_FOLDER_NAME

git switch v2-beta-tao-clang
git stash
git pull

#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
GCC_INSTALL=$(cat $JSON_CONFIG | jq -r ".GCC_INSTALL")

export PATH=$GCC_INSTALL/bin:$PATH
export CC=$GCC_INSTALL/bin/gcc
export CXX=$GCC_INSTALL/bin/g++

export LIBRARY_PATH=$GCC_INSTALL/lib64:$LIBRARY_PATH
export LD_LIBRARY_PATH=$GCC_INSTALL/lib64:$LD_LIBRARY_PATH

SWD=$(pwd)
cd $DCPERF_DIR
git stash
git switch v2-beta
cd $SWD

#!/bin/sh

# Invoke as root
SCRIPT_DIR=$( dirname -- $0 )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

BUILD_LOGS=$SCRIPT_DIR/../build_logs
mkdir -p $BUILD_LOGS

PY_HEADER=$(dirname $(find /usr/include -name pyconfig.h | cut --delimiter " " --fields 1))

BUILD_TIMESTAMP=$(date +%s)
DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
LLVM_INSTALL=$(cat $JSON_CONFIG | jq -r ".LLVM_INSTALL")
PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
PROJECT=$(cat $JSON_CONFIG | jq -r ".PROJECT")

export CC=$LLVM_INSTALL/bin/clang
export CXX=$CC++

export PATH=$LLVM_INSTALL/bin:$PATH
export LIBRARY_PATH=$LLVM_INSTALL/lib/aarch64-unknown-linux-gnu:$LLVM_INSTALL/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$LLVM_INSTALL/lib/aarch64-unknown-linux-gnu:$LLVM_INSTALL/lib:$LD_LIBRARY_PATH
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$PY_HEADER"

echo Clang $CC
echo Clang++ $CXX
export VERBOSE=1

cd $DCPERF_DIR
$PY_ENV/bin/python3 ./benchpress_cli.py --verbose install -f $PROJECT > $BUILD_LOGS/build_$BUILD_TIMESTAMP.log 2>&1

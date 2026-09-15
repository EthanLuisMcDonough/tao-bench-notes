#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
LLVM_INSTALL=$(cat $JSON_CONFIG | jq -r ".LLVM_INSTALL")

export PATH=$LLVM_INSTALL/bin:$PATH
export CC=$LLVM_INSTALL/bin/clang
export CXX=$CC++

TARGET=$($CC -dumpmachine)

export LIBRARY_PATH=$LLVM_INSTALL/lib/$TARGET:$LLVM_INSTALL/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$LLVM_INSTALL/lib/$TARGET:$LLVM_INSTALL/lib:$LD_LIBRARY_PATH

SWD=$(pwd)
cd $DCPERF_DIR
git stash
git switch v2-beta-tao-clang
cd $SWD

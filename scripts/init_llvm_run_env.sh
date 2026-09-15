#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$(realpath $SCRIPT_DIR/../config.json)

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

LLVM_INSTALL=$(cat $JSON_CONFIG | jq -r ".LLVM_INSTALL")
TARGET=$($LLVM_INSTALL/bin/clang -dumpmachine)

export LD_LIBRARY_PATH=$LLVM_INSTALL/lib/$TARGET:$LLVM_INSTALL/lib:$LD_LIBRARY_PATH


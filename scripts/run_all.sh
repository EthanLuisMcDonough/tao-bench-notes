#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )
OUT_DIR=$(realpath $1)

mkdir -p $OUT_DIR

set -e
for toolchain in gcc clang; do
   for mode in Default Release; do
       echo STARTING $mode $toolchain
       $SCRIPT_DIR/build_tao.sh $toolchain $mode
       $SCRIPT_DIR/run_tao.sh $toolchain $OUT_DIR/$toolchain-$mode
   done
done

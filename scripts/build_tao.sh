#!/bin/sh

# Invoke as root
SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    exit 1
fi

TOOLCHAIN=$1
BUILD_KIND=$2
BUILD_LOGS=$SCRIPT_DIR/../build_logs
mkdir -p $BUILD_LOGS

PY_HEADER=$(dirname $(find /usr/include -name pyconfig.h | cut --delimiter " " --fields 1))

BUILD_TIMESTAMP=$(date +%s)
DCPERF_DIR=$(cat $JSON_CONFIG | jq -r ".DCPERF_DIR")
PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
PROJECT=$(cat $JSON_CONFIG | jq -r ".PROJECT")

case $TOOLCHAIN in
    clang) 
        . "$SCRIPT_DIR/init_llvm_build_env.sh"
        ;;
    gcc)
        . "$SCRIPT_DIR/init_gcc_build_env.sh"
        ;;
    *)
        echo INVALID TOOLCHAIN
        exit 1
        ;;
esac

export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$PY_HEADER"

OPT_FLAG=""
case $BUILD_KIND in
    Release)
        OPT_FLAG="-O3"
        ;;
    Default)
        OPT_FLAG="-O2"
        ;;
    Debug)
        OPT_FLAG="-O0"
        ;;
    *)
        echo INVALID BUILD KIND
        exit 1
        ;;
esac
DEFAULT_FLAGS="-g $OPT_FLAG"

export CXXFLAGS=$DEFAULT_FLAGS
export CFLAGS=$DEFAULT_FLAGS

echo CC=$CC
echo CXX=$CXX
echo CFLAGS=$CFLAGS
echo CXXFLAGS=$CXXFLAGS
echo LIBRARY_PATH=$LIBRARY_PATH
echo LD_LIBRARY_PATH=$LD_LIBRARY_PATH
echo CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH
export VERBOSE=1

cd $DCPERF_DIR

LOG_FILE=$BUILD_LOGS/build_$BUILD_TIMESTAMP.log
echo Writing to $LOG_FILE

$PY_ENV/bin/python3 ./benchpress_cli.py --verbose install --toolchain $TOOLCHAIN -f $PROJECT 2>&1 | tee $LOG_FILE

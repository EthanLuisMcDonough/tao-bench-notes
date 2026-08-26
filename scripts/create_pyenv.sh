#!/bin/sh

# Note: This script installs the venv in the directory you specify,
#       not an .env directory inside the specified dir

# E.g. if PY_ENV is /my_dir/this, the env will be installed there,
# NOT /my_dir/this/.env

SCRIPT_DIR=$( realpath $(dirname -- $0) )
JSON_CONFIG=$SCRIPT_DIR/../config.json

if [ ! -f $JSON_CONFIG ]; then
    echo FAILED TO READ CONFIG AT "$JSON_CONFIG"
    return 1
fi

REQUIREMENTS=$(realpath $SCRIPT_DIR/../requirements.txt)

PY_ENV=$(cat $JSON_CONFIG | jq -r ".PY_ENV")
PY_ENV_NAME=$(basename $PY_ENV)
PY_ENV_PATH=$(dirname $PY_ENV)

echo CREATING $PY_ENV
cd $PY_ENV_PATH

uv venv $PY_ENV_NAME --python 3.9 --clear
. $PY_ENV_NAME/bin/activate
uv pip install -r $REQUIREMENTS

echo Installed environment in $PY_ENV

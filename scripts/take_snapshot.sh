#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )

DIRECTORY=$1
DURATION=$2

SERVER_PIDS=""
CLIENT_PIDS=""

for pid in $(pgrep tao_bench_serve); do
    if [[ -z "$SERVER_PIDS" ]]; then
        SERVER_PIDS=$pid
    else
        SERVER_PIDS=$SERVER_PIDS,$pid
    fi
done

if [[ -z "$SERVER_PIDS" ]]; then
    echo "NO SERVER PROCESS FOUND (ENDING PROFILE)";
    exit 1;
fi

for pid in $(pgrep tao_bench_clien); do
    if [[ -z "$CLIENT_PIDS" ]]; then
        CLIENT_PIDS=$pid
    else
        CLIENT_PIDS=$CLIENT_PIDS,$pid
    fi
done

if [[ -z "$CLIENT_PIDS" ]]; then
    echo "NO CLIENT PROCESS FOUND (ENDING PROFILE)";
    exit 1;
fi

TIMESTAMP=$(date +%s)

echo "RUNNING PERF ON CLIENT PIDS \"$CLIENT_PIDS\" + SERVER PIDS \"$SERVER_PIDS\""

cd $DIRECTORY
perf record -p "$SERVER_PIDS" -o tao_server_$TIMESTAMP.data -- sleep $DURATION &
perf record -p "$CLIENT_PIDS" -o tao_client_$TIMESTAMP.data -- sleep $DURATION &
wait


#!/bin/sh

SCRIPT_DIR=$( realpath $(dirname -- $0) )

DIRECTORY=$1

SERVER_PIDS=""
CLIENT_PIDS=""
SLEEP_AMT=5

while [[ -z $SERVER_PIDS ]]; do
    sleep $SLEEP_AMT
    for pid in $(pgrep tao_bench_serve); do
        if [[ -z "$SERVER_PIDS" ]]; then
            SERVER_PIDS=$pid
        else
            SERVER_PIDS=$SERVER_PIDS,$pid
        fi
    done
done

echo "FOUND SERVER $SERVER_PIDS";

#while [[ -z $CLIENT_PIDS ]]; do
#    for pid in $(pgrep tao_bench_clien); do
#        if [[ -z "$CLIENT_PIDS" ]]; then
#            CLIENT_PIDS=$pid
#        else
#            CLIENT_PIDS=$CLIENT_PIDS,$pid
#        fi
#    done
#    if [[ -z $CLIENT_PIDS ]]; then
#        sleep $SLEEP_AMT
#    fi
#done

TIMESTAMP=$(date +%s)

#echo "RUNNING PERF ON CLIENT PIDS \"$CLIENT_PIDS\" + SERVER PIDS \"$SERVER_PIDS\""

cd $DIRECTORY
perf record -p "$SERVER_PIDS" -o tao_server.data
perf report --stdio -i tao_server.data --dso tao_bench_server > tao_server_$TIMESTAMP
rm tao_server.data
#perf record -p "$SERVER_PIDS" -o tao_server_$TIMESTAMP.data &
#perf record -p "$CLIENT_PIDS" -o tao_client_$TIMESTAMP.data &
#wait


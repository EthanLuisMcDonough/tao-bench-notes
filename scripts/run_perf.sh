#!/bin/sh

echo STARTING DELAYED PERF TASK IN $1
sleep 7000s
echo RUNNING PERF
cd $1
perf record -a -g -o bench_perf.data -- sleep 5
echo RAN PERF

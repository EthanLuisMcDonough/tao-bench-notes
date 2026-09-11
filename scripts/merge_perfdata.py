#!/usr/bin/env python3

import re
import os
import sys
import pathlib
import subprocess

if len(sys.argv) != 2:
    print("Invalid number of args")
    exit()

perf_path = pathlib.Path(sys.argv[1])
perf_pat = re.compile("([\d\.]+)% +.+ +\[.\] (.+)", re.MULTILINE)

# kind is client or server
def get_data(p, kind):
    return [x for x in perf_path.iterdir() if x.is_file() and x.name.startswith("tao_" + kind + "_") and x.name.endswith(".data")]

def run_perf(f, kind):
    perf_subp = subprocess.run(["perf", "report", "--stdio", "-i", str(f), "--dso", "tao_bench_" + kind], capture_output=True)
    output = perf_subp.stdout.decode("utf-8")
    matches = re.findall(perf_pat, output)
    percs = [(name, float(perc)) for perc, name in matches if float(perc) != 0.0]
    perc_obj = {}
    for name, perc in percs:
        if name in perc_obj:
            perc_obj[name] += perc
        else:
            perc_obj[name] = perc
    return perc_obj

def merge_data(data, kind):
    perc_sum = {}
    for d in data:
        perc_local = run_perf(d, kind)
        for name, perc in perc_local.items():
            if name in perc_sum:
                perc_sum[name] += perc
            else:
                perc_sum[name] = perc
    return sorted(perc_sum.items(), key=lambda x: x[1], reverse=True)

def run(p, kind):
    data = merge_data(get_data(p, kind), kind)
    with open(p / (kind + "_report.txt"), "w") as report:
        for name, perc in data:
            report.write(str(perc) + "% " + name + "\n")

run(perf_path, "server")

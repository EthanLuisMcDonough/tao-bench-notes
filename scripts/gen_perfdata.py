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
    perf_subp = subprocess.run(["perf", "report", "--stdio", "-i", str(f)], capture_output=True)
    output = perf_subp.stdout.decode("utf-8")
    with open(f.parent / (f.name + ".txt"), "w") as f:
        f.write(output)

def run(p, kind):
    for data in get_data(p, kind):
        run_perf(data, kind)

run(perf_path, "server")

#!/bin/bash

# This script is inteded to be used when Node.js flag --perf-basic-prof is
# enabled.

set -e

PID=$1
shift 1
AUTOCANNON=("$@")
test -n "$PID"
test -n "${AUTOCANNON[*]}"

sudo=(sudo sudo env "PATH=$PATH")

# NOTE(mmarchini): needed to preserve nvm and a possibly custom perf
"${sudo[@]}" perf record -k1 -F99 -g -o out/perf."$PID".data -p "$PID" -- "${AUTOCANNON[@]}"

# shellcheck disable=SC2024
"${sudo[@]}" perf script --fields comm,pid,tid,time,event,ip,sym,dso,period --force -i out/perf."$PID".data > out/perf."$PID".out
"${sudo[@]}" chown mmarchini:mmarchini out/perf."$PID".out
nflxprofile --output out/"$PID".nflxprofile out/perf."$PID".out >/dev/null 2>/dev/null

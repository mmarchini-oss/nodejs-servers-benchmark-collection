#!/bin/bash

# This script is inteded to be used with the flag --perf-prof.
# You probably want a custom Node.js build if you're looking into this file.

set -x
set -e

PID=$1
shift 1
AUTOCANNON=("$@")
test -n "$PID"
test -n "${AUTOCANNON[*]}"

sudo=(sudo sudo env "PATH=$PATH")

# NOTE(mmarchini): needed to preserve nvm and a possibly custom perf
"${sudo[@]}" perf record -k1 -F99 -g -o out/perf."$PID"jit.data -p "$PID" -- "${AUTOCANNON[@]}"
"${sudo[@]}" perf inject -j -i out/perf."$PID"jit.data -o out/perf."$PID"jitinject.data

# shellcheck disable=SC2024
"${sudo[@]}" perf script --fields comm,pid,tid,time,event,ip,sym,dso,period --force -i out/perf."$PID"jitinject.data > out/perf."$PID".out
"${sudo[@]}" chown mmarchini:mmarchini out/perf."$PID".out
nflxprofile --output out/"$PID".nflxprofile out/perf."$PID".out >/dev/null 2>/dev/null

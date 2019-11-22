#!/bin/bash

set -e

PID=$1
shift 1
AUTOCANNON=("$@")
test -n "$PID"
test -n "${AUTOCANNON[*]}"

sudo=(sudo sudo env "PATH=$PATH")

"${sudo[@]}" perf stat -ddd -p "$PID" -- "${AUTOCANNON[@]}"

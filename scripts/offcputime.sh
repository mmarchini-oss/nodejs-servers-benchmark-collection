#!/bin/bash -i

# This script is inteded to be used with the flag --perf-prof.
# You probably want a custom Node.js build if you're looking into this file.

set -e

PID=$1
shift 1
AUTOCANNON=("$@")
test -n "$PID"
test -n "${AUTOCANNON[*]}"

# sudo=(sudo env "PATH=$PATH")
offwaketime="$(which offwaketime)"
test -n "$offwaketime"

# NOTE(mmarchini): needed to preserve nvm and a possibly custom perf
# "${sudo[@]}" offwaketime -f -p "$PID" > "out/$PID.stacks" &
sudo "$offwaketime" --stack-storage-size 4096 -f -p "$PID" > "out/$PID.stacks" &
sleep 2s
offpid=$!
"${AUTOCANNON[@]}"

sudo kill -INT "$offpid"
wait "$offpid"

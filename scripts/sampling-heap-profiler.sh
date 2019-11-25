#!/bin/bash

# This script is inteded to be used with the flag --perf-prof.
# You probably want a custom Node.js build if you're looking into this file.

set -e

PID=$1
shift 1
AUTOCANNON=("$@")
test -n "$PID"
test -n "${AUTOCANNON[*]}"

# NOTE(mmarchini): needed to preserve nvm and a possibly custom perf
kill -USR1 "$PID"
mkfifo ./out/fifo
echo foo
websocat "$(curl -s http://localhost:9229/json | jq -r '.[0].webSocketDebuggerUrl')" < ./out/fifo > ./out/$PID.inspector.out &
echo foo2
exec 3>./out/fifo
echo bar
echo '{"method": "HeapProfiler.enable", "id": 1}' > ./out/fifo
echo '{"method": "HeapProfiler.startSampling", "id": 2}' > ./out/fifo
"${AUTOCANNON[@]}"
echo '{"method": "HeapProfiler.stopSampling", "id": 3}' > ./out/fifo
exec 3>&-
sleep 1s
tail -n1 ./out/$PID.inspector.out | jq '.result.profile' > "./out/$PID.heapprofile"
rm ./out/$PID.inspector.out ./out/fifo

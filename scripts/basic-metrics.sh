#!/bin/bash

set -e

PID=$1
shift 1
AUTOCANNON=("$@")
test -n "$PID"
test -n "${AUTOCANNON[*]}"

vmstat 1 > "out/$PID.vmstat" &
mpstat -P ALL 1 > "out/$PID.mpstat" &
pidstat -p "$PID" -t 1 > "out/$PID.pidstat" &
iostat -xz 1 > "out/$PID.iostat" &
sar -n DEV 1 > "out/$PID.sardev" &
sar -n TCP,ETCP 1 > "out/$PID.sartcp" &

"${AUTOCANNON[@]}"

pkill -INT -P $$

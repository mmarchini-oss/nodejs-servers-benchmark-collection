#!/bin/bash

set -x
set -e

function cleanup {
  pkill -P "$$" node
}

trap cleanup EXIT

OLD=$1
NEW=$2
SUITE=${3:-restify}
BENCH=${4:-restify}
shift 4
SCRIPT=( "$@" )

test -n "$OLD"
test -n "$NEW"
# test -n "$SCRIPT"
test -n "$SUITE"
test -n "$BENCH"

rm -rf out
mkdir -p out

out=

# NOTE(mmarchini): It doesn't matter which one we source when linting, since
# both should expose the same functions.
# shellcheck source=./benchmarks/restify.sh
source "./benchmarks/$SUITE.sh"

function run() {
  node="$1"
  v=$($node --version)
  SERVER_NAME="${BENCH}-${v}"

  # Start the server & get PID
  start_bench "$node" "$BENCH"
  ps aux | grep -v slack | grep -v grep | grep node
  pid="$(pgrep -P "$$" node)"

  # Run autocannon, alternatively wrapped with a script to capture metrics
  out="out/$SERVER_NAME.json"
  AUTOCANNON=(./autocannon "$out" -c 100 -p 10 -d 40 --json localhost:3000)
  if [ -n "${SCRIPT[*]}" ]; then
    "${SCRIPT[@]}" "$pid" "${AUTOCANNON[@]}"
  else
    "${AUTOCANNON[@]}"
  fi
  kill "$pid"
}

run "$OLD"
a="$out"
run "$NEW"
b="$out"

npx autocannon-compare "$a" "$b" > out/results.json
cat out/results.json

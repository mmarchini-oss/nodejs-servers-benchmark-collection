#!/bin/bash

set -e

function cleanup {
  if pgrep -P "$$" node; then
    echo 1
    pkill -P "$$" node
    echo 2
  fi
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
  pid="$(pgrep -P "$$" node)"
  echo "PID: $pid"

  # Run autocannon, alternatively wrapped with a script to capture metrics
  out="out/$SERVER_NAME.json"
  url=$(get_url "$BENCH")
  echo "Warming up..."
  npx autocannon -c 100 -p 10 -d 40 "$url" >/dev/null 2>/dev/null
  echo "Warmed up, running benchmarks"
  AUTOCANNON=(./autocannon "$out" -c 100 -p 10 -d 40 --json "$url")
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

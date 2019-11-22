#!/bin/bash

set -e

function start_bench() {
  node="$1"
  bench="$2"
  pushd "./benchmarks/fastify/"
  "$node" "benchmarks/$bench.js" &
  popd
  return
}

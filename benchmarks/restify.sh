#!/bin/bash

set -e

function start_bench() {
  node=($1)
  bench="$2"
  pushd "./benchmarks/restify/benchmark" > /dev/null
  "${node[@]}" "benchmarks/$bench.js" &
  popd > /dev/null
  return
}

function get_url() {
  set -e

  bench="$1"
  pushd "./benchmarks/restify/benchmark" > /dev/null
  path=$(node -e "const b=require('./benchmarks/$bench.js'); console.log(b.url || '/')")
  popd > /dev/null
  if [ -z "$path" ]; then
    echo "localhost:3000"
    return
  fi
  echo "$path"
}

function list() {
  find ./benchmarks/restify/benchmark/benchmarks -maxdepth 1 -name "*.js" -exec basename {} \; | cut -f 1 -d '.'
}

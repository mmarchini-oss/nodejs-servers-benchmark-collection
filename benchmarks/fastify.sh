#!/bin/bash

set -e

function start_bench() {
  node=($1)
  bench="$2"
  pushd "./benchmarks/fastify/"
  "${node[@]}" "benchmarks/$bench.js" &
  popd
  return
}

function get_url() {
  bench="$1"
  echo "localhost:3000"
}

function list() {
  echo "fastify"
  echo "restify"
  echo "express"
  echo "hapi"
  echo "bare"
}

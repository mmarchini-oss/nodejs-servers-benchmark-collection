#!/bin/bash

suites="$(find ./benchmarks/ -maxdepth 1 -name "*.sh" -exec basename {} \; | cut -f 1 -d '.')"

for suite in $suites; do
  source "benchmarks/$suite.sh"
  benchmarks="$(list)"
  for bench in $benchmarks; do
    echo "$suite" "$bench"
  done
done


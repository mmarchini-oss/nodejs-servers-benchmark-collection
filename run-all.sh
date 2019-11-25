#!/bin/bash

set -e

OLD=$1
NEW=$2
shift 2
SCRIPT=( "$@" )

test -n "$OLD"
test -n "$NEW"

while read -r line; do
  suite=$(echo "$line" | cut -d ' ' -f 1)
  bench=$(echo "$line" | cut -d ' ' -f 2)
  echo "Running $line"
  ./run.sh "$OLD" "$NEW" "$suite" "$bench" "${SCRIPT[@]}"
  mv out "out-$suite-$bench"
done <<<"$(./list.sh)"

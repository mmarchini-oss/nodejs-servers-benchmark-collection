#!/bin/bash

previous_governor=''
previous_min_freq=''

function bench_start() {
  echo "Disabling CPU scaling"
  previous_governor="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
  previous_min_freq="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)"
  max_freq="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)"
  echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
  echo "$max_freq" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq > /dev/null
}

function bench_stop() {
  echo "Re-enabling CPU scaling"
  echo "$previous_governor" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
  echo "$previous_min_freq" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq > /dev/null
}

bench_start
"$@"
bench_stop

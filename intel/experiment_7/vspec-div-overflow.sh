#!/usr/bin/env bash

set -e

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 24 * 3600 ))

WORK_DIR=$(realpath $SCRIPT_DIR/../../)
echo "HOME=$WORK_DIR"


instructions="$WORK_DIR/base.json"
timestamp=$(date '+%y-%m-%d-%H-%M')

results=$SCRIPT_DIR/results
mkdir -p $results

logfile="$SCRIPT_DIR/results/div-overflow-$timestamp.log"
echo "[+] Fuzzing #DE (overflow) with vspec-NI; Log at $logfile"
rvzr fuzz -s $instructions -c  $SCRIPT_DIR/div-overflow.yaml -i 100 -n 100000000 --timeout $TIMEOUT  -w $SCRIPT_DIR/results/violations/ &> $logfile
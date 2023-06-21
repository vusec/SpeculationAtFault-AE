#!/usr/bin/env bash

set -e

contract="vspec-CI"

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 24 * 3600 ))

WORK_DIR=$(realpath $SCRIPT_DIR/../../)

instructions="$WORK_DIR/base.json"
timestamp=$(date '+%y-%m-%d-%H-%M')

results=$SCRIPT_DIR/results
mkdir -p $results

logfile="$SCRIPT_DIR/results/vspec-CI-GP-$timestamp.log"
echo "[+] Fuzzing #GP (non-canonical accesses) with $contract; Log at $logfile"
rvzr fuzz -s $instructions -c  $SCRIPT_DIR/vspec-CI-GP.yaml -i 100 -n 100000000 --timeout $TIMEOUT  -w $SCRIPT_DIR/results/violations/ &> $logfile
#!/usr/bin/env bash

set -e

contract="seq"

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 24 * 3600 ))

WORK_DIR=$(realpath $SCRIPT_DIR/../../)

instructions="$WORK_DIR/base.json"
timestamp=$(date '+%y-%m-%d-%H-%M')

results=$SCRIPT_DIR/results
mkdir -p $results

logfile="$SCRIPT_DIR/results/seq-assist-accessed-$timestamp.log"
echo "[+] Fuzzing ucode-assist (accessed bit) with $contract; Log at $logfile"
rvzr fuzz -s $instructions -c  $SCRIPT_DIR/seq-assist-accessed.yaml -i 100 -n 100000000 --timeout $TIMEOUT  -w $SCRIPT_DIR/results/violations/ &> $logfile

#!/usr/bin/env bash

set -e

contract="div-vspec-ops"

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 24 * 3600 ))

WORK_DIR=$(realpath $SCRIPT_DIR/../../)
echo "HOME=$WORK_DIR"

revizor_src="$WORK_DIR/sca-fuzzer"
instructions="$revizor_src/base.json"
timestamp=$(date '+%y-%m-%d-%H-%M')

results=$SCRIPT_DIR/results
mkdir -p $results

logfile="$SCRIPT_DIR/results/div-zero-$timestamp.log"
echo "[+] Fuzzing #DE (divide-by-zero) with $contract; Log at $logfile"
python $revizor_src/revizor.py fuzz -s $instructions -c  $SCRIPT_DIR/div-zero-vspec-ops.yaml -i 100 -n 100000000 --timeout $TIMEOUT  -w $SCRIPT_DIR/results/violations/ &> $logfile
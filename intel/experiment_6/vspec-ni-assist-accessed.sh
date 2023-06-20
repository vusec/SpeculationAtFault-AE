#!/usr/bin/env bash

set -e

contract="vspec-NI"

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 24 * 3600 ))

WORK_DIR=$(realpath $SCRIPT_DIR/../../)
echo "HOME=$WORK_DIR"


instructions="$WORK_DIR/base.json"
timestamp=$(date '+%y-%m-%d-%H-%M')

results=$SCRIPT_DIR/results
mkdir -p $results

cp $SCRIPT_DIR/assist-accessed.yaml $SCRIPT_DIR/assist-accessed-NI.yaml
echo ""                               >> $SCRIPT_DIR/assist-accessed-NI.yaml
echo "contract_execution_clause:"     >> $SCRIPT_DIR/assist-accessed-NI.yaml
echo "  - nullinj-assist"    >> $SCRIPT_DIR/assist-accessed-NI.yaml

logfile="$SCRIPT_DIR/results/assist-accessed-dh-$timestamp.log"
echo "[+] Fuzzing ucode-assist (accessed bit) with $contract; Log at $logfile"
rvzr fuzz -s $instructions -c  $SCRIPT_DIR/assist-accessed-NI.yaml -i 100 -n 100000000 --timeout $TIMEOUT  -w $SCRIPT_DIR/results/violations/ &> $logfile

#!/usr/bin/env bash

set -e

contract="vspec-NI"

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 12 * 3600 ))
die() { echo "$*" >&2; exit 2; }
while getopts t:-: OPT; do
  # support long options: https://stackoverflow.com/a/28466267/519360
  if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$OPT" in
    t | timeout )    TIMEOUT=$OPTARG ;;
    ??* )          die "Illegal option --$OPT" ;;
    ? )            exit 2 ;;
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
echo "Timeout=$TIMEOUT (seconds)"

WORK_DIR=$(realpath $SCRIPT_DIR/../../)
echo "HOME=$WORK_DIR"


instructions="$WORK_DIR/base.json"
timestamp=$(date '+%y-%m-%d-%H-%M')

results=$SCRIPT_DIR/results
mkdir -p $results

logfile="$SCRIPT_DIR/results/div-zero-$timestamp.log"
echo "[+] Fuzzing #DE (divide-by-zero) with $contract; Log at $logfile"
rvzr fuzz -s $instructions -c  $SCRIPT_DIR/div-zero.yaml -i 100 -n 100000000 --timeout $TIMEOUT  -w $SCRIPT_DIR/results/violations/ &> $logfile
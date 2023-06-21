#!/usr/bin/env bash

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)

echo "======== Experiment 1 ========"
cd $SCRIPT_DIR/intel/experiment_1
./run.sh "$@"

echo "======== Experiment 2 ========"
if  grep -q "l1tf" /proc/cpuinfo || grep -q "mds" /proc/cpuinfo  ; then
    cd $SCRIPT_DIR/intel/experiment_2/vs-all-PF/
    ./run.sh "$@"
else
    cd $SCRIPT_DIR/intel/experiment_2/vs-ni-PF/
    ./run.sh "$@"
fi

echo "======== Experiment 3 ========"
cd $SCRIPT_DIR/intel/experiment_3
./run.sh "$@"

echo "======== Experiment 4 ========"
cd $SCRIPT_DIR/intel/experiment_4
./run.sh "$@"

echo "======== Experiment 5 ========"
cd $SCRIPT_DIR/intel/experiment_5
./run.sh "$@"

echo "======== Experiment 6 ========"
if grep -q "l1tf" /proc/cpuinfo || grep -q "mds" /proc/cpuinfo  ; then
    cd $SCRIPT_DIR/intel/experiment_6/vs-all-assist/
    ./run.sh "$@"
else
    cd $SCRIPT_DIR/intel/experiment_6/vs-ni-assist/
    ./run.sh "$@"
fi

echo "======== Experiment 7 ========"
cd $SCRIPT_DIR/intel/experiment_7
./run.sh "$@"

echo "======== Experiment 8 ========"
cd $SCRIPT_DIR/intel/experiment_8
./run.sh "$@"

echo "======== Experiment 9 ========"
cd $SCRIPT_DIR/intel/experiment_9
./run.sh "$@"

#!/usr/bin/env bash

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)

echo "======== Experiment 1 ========"
cd $SCRIPT_DIR/amd/experiment_1
./run.sh "$@"

echo "======== Experiment 2 ========"
cd $SCRIPT_DIR/amd/experiment_2
./run.sh "$@"

echo "======== Experiment 3 ========"
cd $SCRIPT_DIR/amd/experiment_3
./run.sh "$@"

echo "======== Experiment 4 ========"
cd $SCRIPT_DIR/amd/experiment_4
./run.sh "$@"

echo "======== Experiment 5 ========"
cd $SCRIPT_DIR/amd/experiment_5
./run.sh "$@"

echo "======== Experiment 6 ========"
cd $SCRIPT_DIR/amd/experiment_6
./run.sh "$@"

echo "======== Experiment 7 ========"
cd $SCRIPT_DIR/amd/experiment_7
if grep -m1 "cpu family" /proc/cpuinfo | grep "23"  ; then
    ./run-vspec-all.sh "$@"
else
    ./run-vspec-ops.sh "$@"
fi

echo "======== Experiment 8 ========"
cd $SCRIPT_DIR/amd/experiment_6
./run.sh "$@"

echo "======== Experiment 9 ========"
cd $SCRIPT_DIR/amd/experiment_6
./run.sh "$@"

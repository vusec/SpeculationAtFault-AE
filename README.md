# Artifact Evaluation Submission [Usenix'23]
**Paper:** "Speculation at Fault: Modeling and Testing Microarchitectural Leakage of CPU Exceptions"

## Requirements & Dependencies
The fuzzer includes a kernel module that implements the executor. The executor sets MSR registers in order to disable the hardware prefetcher amd performance counters. 
By overwriting the OS-defined IDT, the executor suppresses the handling of exceptions on the running core. It is important to note that this may affect other jobs running on your system. 
The fuzzer executes randomly generated programs in kernel space, intended to throw exceptions. Even though the executor provides a stable and isolated environment, it may adversely affect the stability of your system.

### Hardwre Requirements
The artifact requires at least one physical machine with an Intel CPU and one physical machine with AMD CPU. Root access is required. 
Speculative Store Bypass (SSB) patch must be enabled.

### Software Requirements

* Linux v5.1+
* Linux Kernel Headers
* Python 3.9+
* [Unicorn 1.0.3](https://www.unicorn-engine.org/docs/)
* [GNU datamash](https://www.gnu.org/software/datamash/)

For tests, also [Bash Automated Testing System](https://bats-core.readthedocs.io/en/latest/index.html) and [mypy](https://mypy.readthedocs.io/en/latest/getting_started.html#installing-and-running-mypy)

Other Python modules are automatically installed. These include: 
* Python bindings to Unicorn:
* Python packages `pyyaml`, `types-pyyaml`, `numpy`:

### System Configuration
For more stable results, disable hyperthreading (there's usually a BIOS option for it).

### Installing the Artifact (5 human-minutes + 5 compute-minuts)

1. Get submodules:
```bash
# from the root directory of this project
git submodule update --init --recursive
```
2. Install Revizor Python Package
Install Python 3.9 and create a virtual environment:
```
sudo apt install python3.9 python3.9-venv
python3.9 -m pip install virtualenv
python3.9 -m venv ~/venv-revizor
source ~/venv-revizor/bin/activate
```

Install the build module:
```
pip3 install build
```

Install from source (This will also install dependencies):

```bash
cd sca-fuzzer
make install
```

 3. Install Revizor Executor (Kernel module)
```bash
# building a kernel module require kernel headers
sudo apt-get install linux-headers-$(uname -r)

# build the executor
cd src/x86/executor
make uninstall  # the command will give an error message, but it's ok!
make clean
make
make install
```

4. Download ISA spec

```bash
rvzr download_spec -a x86-64 --extensions BASE SSE SSE2 CLFLUSHOPT CLFSH MPX --outfile base.json
```
or
```bash
python sca-fuzzer/revizor.py download_spec -a x86-64 --extensions BASE SSE SSE2 CLFLUSHOPT CLFSH MPX --outfile base.json
```

### Basic Usability Test
From the base directory, try to run:

```bash
python sca-fuzzer/revizor.py fuzz -s sca-fuzzer/base.json -c basic/seq-BP.yaml  -i 100 -n 100000000
```

Revizor will start fuzzing *Breakpoint* exception.  Revizor should not report any violation since #BR does not trigger speculation. Press *CTRL-C* to interrupt.

Now, try the following command to fuzz page fault (#PF).
```bash
python sca-fuzzer/revizor.py fuzz -s sca-fuzzer/base.json -c basic/seq-PF.yaml  -i 100 -n 100000000
```

Revizor should exit and report a violation after few seconds:

```bash
> Validating violation...> Priming  47             

================================ Violations detected ==========================
Contract trace:
 9099680964197786616 (hash)
Hardware traces:
 Inputs [65]:
  ^.^^.................................^..^.........^.........^^^^
 Inputs [165]:
  ^.^^....................^^..............^.........^...^.....^^^^


================================ Statistics ===================================

Test Cases: 1
Inputs per test case: 200.0
Violations: 1
Effectiveness: 
  Total Cls: 100.0
  Effective Cls: 100.0
Discarded Test Cases:
  Speculation Filter: 0
  Observation Filter: 0
  No Fast-Path Violation: 0
  Noise-Based FP: 0
  No Max-Nesting Violation: 0
  Tainting Mistakes: 0
  Flaky Tests: 0
  Priming Check: 0

Duration: 4.3
Finished at 13:14:43
```


## Experiments

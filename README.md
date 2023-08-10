# Artifact Evaluation Submission [Usenix'23]

Paper: ["Speculation at Fault: Modeling and Testing Microarchitectural Leakage of CPU Exceptions"](https://www.usenix.org/system/files/usenixsecurity23-hofmann.pdf)

### Table of Contents  
- [How to Install](#requirements)  
   - [Hardware requirements](#hw-requirements)
   - [Software requirements](#sw-requirements)
   - [System configuration](#configuration)
   - [Installation](#install)
   - [Basic Usability Test](#basic-test)
- [Claims & Experiments](#claims)
   - [Experiments Intel](#intel)
   - [Experiments AMD](#amd) 


## How to Install <a name="requirements"/>

The fuzzer includes a kernel module that implements the executor. The executor sets MSR registers in order to disable the hardware prefetcher amd performance counters. 
By overwriting the OS-defined IDT, the executor suppresses the handling of exceptions on the running core. It is important to note that this may affect other jobs running on your system. 
The fuzzer executes randomly generated programs in kernel space, intended to throw exceptions. Even though the executor provides a stable and isolated environment, it may adversely affect the stability of your system.

### Hardware Requirements  <a name="hw-requirements"/>
Evaluating this artifact requires at least one physical machine with root access.
Ideally the reviewer has access to both one machine with Intel (KabyLake or CoffeeLake) and AMD (Zen+ or Zen3) CPU.

If only one such machine is available, the experiments can still be reproduced for just that machine. 
For AMD Zen2, we expect to obtain the same results as for Zen3.

To obtain stable results, the machine(s) should not be actively used by any other software.

### Software Requirements  <a name="sw-requirements"/>

* Linux v5.1+
* Linux Kernel Headers

```
# On Ubuntu
sudo apt install linux-headers-$(uname -r)
```

* Python 3.9+ and Virtual Environment

```
# On Ubuntu
sudo apt install python3.9 python3.9-venv
python3.9 -m pip install virtualenv
```

<!-- 
Other Python modules are automatically installed. These include: 
* Python bindings to Unicorn:
* Python packages `pyyaml`, `types-pyyaml`, `numpy`: -->

### System Configuration  <a name="configuration"/>

For more stable results, disable hyperthreading (there's usually a BIOS option for it).

### Installing the Artifact (5 human-minutes + 5 compute-minuts)  <a name="install"/>

1. Install Revizor Python Package
   
Create a virtual environment:

```
# On Ubuntu
python3 -m venv ~/venv-revizor
```
Alternatively, use virtualenv:
```
python3 -m virtualenv ~/venv-revizor
```

and activate the virtual environment
```
source ~/venv-revizor/bin/activate
```

Install the package:

```
pip install revizor/revizor_fuzzer-1.2.3-py3-none-any.whl
```

Check installation:

```
rvzr

# Should print the following:
# usage: rvzr {fuzz,analyse,reproduce,minimize,generate,download_spec} ...
# rvzr: error: the following arguments are required: subparser_name
```

2. Install Revizor Executor (Kernel module)
   
```bash
cd revizor/executor
make uninstall  # the command will give an error message, but it's ok!
make clean
make
make install
cd -
```

**Note:** *Secure boot must be turned off in the BIOS settings. Otherwise, you should sign the module with an enrolled key. 
On Ubuntu, you find more information [here](https://ubuntu.com/blog/how-to-sign-things-for-secure-boot)*

3. Download ISA spec

```bash
rvzr download_spec -a x86-64 --extensions BASE SSE SSE2 CLFLUSHOPT CLFSH MPX --outfile base.json
```

### Basic Usability Test  <a name="basic-test"/>
For Intel CPUs, move into the `intel` directory:
```bash
cd intel
```

Otherwise, on AMD: 
```bash
cd amd
```

To run the basic test:
```bash
rvzr fuzz -s ../base.json -c basic/seq-BP.yaml -i 10 -n 100
```

This command will start a small fuzzing campaign testing breakpoint exceptions with 100 test cases, each tested with 10 inputs.
The command is expected to terminate without reporting a violation.

Now, try the following command to fuzz page faults (#PF):

```bash
rvzr fuzz -s ../base.json -c basic/seq-PF.yaml  -i 100 -n 100000000
```

Revizor should exit and report a violation after few seconds:

```bash
> Validating violation...> Priming  47s             

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


## Claims & Experiments  <a name="claims"/>
The main results are reported in Table 1 of the original paper.
The results can be summarized in the following claims:

- **C1** - #PF complies with *CT-VS-All* on Intel Kaby Lake, with *CT-VS-NI* on Intel CoffeeLake, and with *CT-DH* on AMD.
- **C2** - #GP complies with *CT-VS-CI* on AMD. On Intel, #GP does not satisfy any contract.
- **C3** - (Intel only) #BR complies with *CT-DH*. (E5)
- **C4** - ucode-assists comply with *CT-SEQ* on AMD and with *CT-VS-All* on Intel (*CT-VS-NI* on CoffeeLake).
- **C5** - #DE complies with *CT-VS-Ops* on Intel and AMD Zen3, and with *CT-VS-All* on AMD Zen+.
- **C6** - #UD, #DB, and #BP comply with *CT-SEQ* on all machines. 

### Experiments design
Our experiments serve two purposes: (1) validating our claims regarding which contract satisfies which exception on which machine, and (2) confirming Revizor's effectiveness in generating counterexamples.
For each exception, we therefore propose one experiment that validates the correct contract and one experiment that finds a counterexample for the next more restrictive contract (if one exists).

In the interest of time, we run each experiment for 12h or until a violation is found.
The timeout can be increased with the *--timeout* option we included in the scripts.
For our paper, each experiment ran for 24h.
Remember though that Revizor is based on random testing,  it is thus possible that a violation is not found within 12h.
If this is the case, we suggest to repeat the experiment and increase the timeout.

### How-to: <a name="how-to"/>
We split our experiments according to the type of machine under test.
Scripts for the experiments are grouped into a directory for Intel and one for AMD.

Inside each directory, there is one `run.sh` script to start the experiment
An optional timeout (given in seconds) can be set with the `--timeout` option (e.g., `./run.sh --timeout 86400` for a 24h timeout).

Running the script will create a subdirectory  `results` inside the experiment directory, where logs are stored
When the script terminates, you can inspect the log to determine whether Revizor detected a violation.
Violations (if any) are stored in subdirectories inside *results/violations/*.  
Each violation directory will contain the program, the inputs, and the configuration file.


### Intel <a name="intel"/>
From the base directoy, to run all the experiments with a signle command:

```bash
./run-intel.sh
````

Each test runs for 12h by default. 
You can use the *--timeout* option to pass a different argument to Revizor:

```bash
./run-intel.sh --timeout=8600
````

#### Experiment 1 (C1 - page faults - violation) [1/2 machine hours]
Test each page fault class (invalid, read-only, SMAP) against *CT-DH*.

```bash
./intel/experiment_1/run.sh
```
Alternatively, for a longer run (24h):

```bash
./intel/experiment_1/run.sh --timeout=8600
```

**Result:** violation (for all classes)

#### Experiment 2 (C1 - page faults - correct) [36 machine hours]
Test each page fault class (invalid, read-only, SMAP) against *CT-VS-NI* on CoffeeLake (and newer), resp. against *CT-VS-All* (on KabyLake and older).

On CoffeeLake (and newer):
```bash
./intel/experiment_2/vs-ni-PF/run.sh
```
On KabyLake (and older)
```bash
./intel/experiment_2/vs-all-PF/run.sh
```

**Result:** no violation. 

#### Experiment 3 (C2 - non-canonical accesses -  violation) [12 machine hours]
Test #GP (i.e., non-canonical memory accesses) against *CT-VS-All*

```bash
./intel/experiment_3/run.sh
```

**Result:** violation. Due to the complexity of the contract, finding a violation may take several hours (it was 11h when we ran the experiment).

#### Experiment 4 (C3 - Mpx - correct) [24 machine hours]
 Test MPX against *CT-DH*.

```bash
./intel/experiment_4/run.sh
```
**Result:** no violation. 

#### Experiment 5 (C4 - ucode-assists - violation) [1/6 machine hours]
 Test both variants of ucode assists (Access bit and Dirty bit) against *CT-DH*.

```bash
./intel/experiment_5/run.sh
```

**Result:** violation (for both variants)

#### Experiment 6 (C4 - ucode-assists - correct} [24 machine hours] 
Fuzz both variants against *CT-VS-NI* on CoffeeLake (and newer), resp. against *CT-VS-All* (on KabyLake and older).

On CoffeeLake (and newer):
```bash
./intel/experiment_6/vs-ni-assist/run.sh
```
On KabyLake (and older)
```bash
./intel/experiment_6/vs-all-assist/run.sh
```

**Result:** no violation.

#### Experiment 7 (C5 - division - violation) [2 machine hours] 
Test both types of division errors (divide-by-zero and division overflow) against *CT-VS-NI*

```bash
./intel/experiment_7/run.sh
```
**Result:** violation (for both variants)

#### Experiment 8 (C5 - division - correct) [24 machine hours] 
Test both types of division errors (divide-by-zero and division overflow) against *CT-VS-Ops*.

```bash
./intel/experiment_8/run.sh
```
**Result:** no violation.

#### Experiment 9 (C6 - others - correct) [36 machine hours]
Test #UD, #DB and #BP against *CT-SEQ*. 

```bash
./intel/experiment_9/run.sh
```

**Result:** no violation.

### AMD <a name="amd"/>
From the base directoy, to run all the experiments with a single command:
```bash
./run-amd.sh
```
or to run each test for 24h: 

```bash
./run-amd.sh --timeout=8600
````

#### Experiment 1 (C1 - page faults - violation) [1/6 machine hours]: 
Test each page fault class (invalid, read-only, SMAP) against *CT-SEQ*.

```bash
./amd/experiment_1/run.sh
```

**Result:** violation (for all classes).

#### Experiment 2 (C1 - page faults - correct) [36 machine hours]
Test each page fault class (invalid, read-only, SMAP) against *CT-DH*.

```bash
./amd/experiment_2/run.sh
```
**Result:** no violation (for all classes).

#### Experiment 3 (C2 - non-canonical accesses -  violation) [1/12 machine hours]
Test non-canonical accesses against *CT-DH*.

```bash
./amd/experiment_3/run.sh
```
**Result:** violation.

#### Experiment 4 (C2 - non-canonical accesses) -  correct} [12 machine hours]
Test non-canonical accesses against *CT-VS-CI*.

```bash
./amd/experiment_4/run.sh
```
**Result:** no violation.


#### Experiment 5 (C4 - ucode-assists - correct) [24 machine hours]
Test both variants (Access bit and Dirty bit) against *CT-SEQ*.
 
```bash
./amd/experiment_5/run.sh
```
**Result:** no violation.

#### Experiment 6 (C5 - division - violation) [2 machine hours]
 Test both type of division errors (divide-by-zero and division overflow) against *CT-VS-NI*.

```bash
./amd/experiment_6/run.sh
```
**Result:** no violation (for both variants).


#### Experiment 7 (C5 - division by zero - correct) [12 machine hours]
Test division-by-zero errors against *CT-VS-Ops* on Zen3 (or newer), resp. against *CT-VS-All* on Zen+ (or older). 
For Zen2 (which was not part of our setup), we expect *CT-VS-Ops* to hold as well.

On AMD Zen2 and Zen3:
```bash
./amd/experiment_7/run-vspec-ops.sh
```

On Zen+ (and older):
```bash
./amd/experiment_7/run-vspec-all.sh
```
**Result:** no violation.


#### Experiment 8 (C5 - division overflow - correct) [12 machine hours]
Test division overflows against *CT-VS-Ops*.
```bash
./amd/experiment_8/run.sh
```
**Result:** no violation.

#### Experiment 9 (C6 - others - correct) [36 machine hours]

```bash
./amd/experiment_9/run.sh
```
**Result:** no violation.

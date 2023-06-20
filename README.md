# Artifact Evaluation Submission [Usenix'23]

**Paper:** "Speculation at Fault: Modeling and Testing Microarchitectural Leakage of CPU Exceptions"

## Requirements & Dependencies

The fuzzer includes a kernel module that implements the executor. The executor sets MSR registers in order to disable the hardware prefetcher amd performance counters. 
By overwriting the OS-defined IDT, the executor suppresses the handling of exceptions on the running core. It is important to note that this may affect other jobs running on your system. 
The fuzzer executes randomly generated programs in kernel space, intended to throw exceptions. Even though the executor provides a stable and isolated environment, it may adversely affect the stability of your system.

### Hardware Requirements
Evaluating this artifact requires at least one physical machine with root access.
Ideally the reviewer has access to both one machine with Intel (KabyLake or CoffeeLake) and AMD (Zen+ or Zen3) CPU.

If only one such machine is available, the experiments can still be reproduced for just that machine. 
For AMD Zen2, we expect to obtain the same results as for Zen3.

To obtain stable results, the machine(s) should not be actively used by any other software.

### Software Requirements

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

### System Configuration

For more stable results, disable hyperthreading (there's usually a BIOS option for it).

### Installing the Artifact (5 human-minutes + 5 compute-minuts)

1. Install Revizor Python Package
   
Create a virtual environment:

```
# On Ubuntu
python3 -m venv ~/venv-revizor
source ~/venv-revizor/bin/activate
```

Install the package:

```
pip install revizor/revizor-1.2.3-py3-none-any.whl 
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

3. Download ISA spec

```bash
rvzr download_spec -a x86-64 --extensions BASE SSE SSE2 CLFLUSHOPT CLFSH MPX --outfile base.json
```

### Basic Usability Test

From the base directory, try to run:

```bash
rvzr fuzz -s base.json -c basic/seq-BP.yaml -i 10 -n 100
```

This command will start a small fuzzing campaign testing the *Breakpoint* with 100 test cases, each tested with 10 inputs.
The command is expected to terminate without reporting a violation.

Now, try the following command to fuzz page faults (#PF):

```bash
rvzr fuzz -s base.json -c basic/seq-PF.yaml  -i 100 -n 100000000
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


## Claims & Experiments
The main results are reported in Table 1 of the original paper.
The results can be summarized in the following claims:

- **C1** - \#PF complies with *CT-VS-All* on Intel *CT-VS-NI* on CoffeeLake) and with *CT-DH* on AMD.
- **C2** - #GP complies with *CT-VS-CI* on AMD. On Intel, #GP does not satisfy any contract.
- **C3** - (Intel only) #BR complies with *CT-DH*. (E5)
- **C4** - ucode-assists comply with *CT-SEQ* on AMD and with CT*-VS-All* on Intel (*CT-VS-NI* on CoffeeLake).
- **C5** - #DE complies with *CT-VS-Ops* on Intel and AMD Zen3, and with *CT-VS-All* on AMD Zen+.
- **C6** - #UD, #DB, and #BP comply with *CT-SEQ* on all machines. 

### Experiments design
Our experiments serve two purposes: (1) validating our claims regarding which contract satisfies which exception on which machine, and (2) confirming Revizor's effectiveness in generating counterexamples.
For each exception, we therefore propose one experiment that validates the correct contract and one experiment that finds a counterexample for the next more restrictive contract (if one exists).
Each experiments runs for 24h or until a violation is found.
Remember though that Revizor is based on random testing,  it is thus possible (but unlikely) that a violation is not found within 24h.
If this is the case, we suggest to repeat the experiment.
We split our experiments according to the type of machine under test. 

### How-to:
This artifact has one directory for each experiment and architecture.
For example, the scripts to run *Experiment 1* on Intel CPUs are stored inside \code{./intel/experiment\_1/}.

The scripts produce log files that are store inside a `results` subdirectory (e.g., `./intel/experiment_1/results/` for *Experiment 1* on Intel).

### Experiment 1

#### Intel

```bash
./intel/experiment_1/run.sh
```

Test each page fault class (invalid, read-only, SMAP) against *CT-DH*.

#### AMD
```bash
./amd/experiment_1/run.sh
```
Test each page fault class (invalid, read-only, SMAP) against *CT-SEQ*.

**Result:** Revizors finds a violation for each page fault class and contract. You can find a report in the log files in the `results` subdirectory.

### Experiment 2
#### Intel

```bash
./intel/experiment_2/run.sh
```
Test each page fault class (invalid, read-only, SMAP) against *CT-VSPEC-All*.

#### AMD

```bash
./amd/experiment_2/run.sh
```

Test each page fault class (invalid, read-only, SMAP) against *CT-DH*.

**Result:** After running for 24h on each page fault class and contract, no violation is found. 

# Synchronous FIFO UVM Verification Project

This repository contains a complete UVM-based verification environment that I built to verify a parameterized Synchronous FIFO design. I developed both the RTL and the UVM testbench structure, and ran simulations to achieve verification closure.

## What I Implemented

### 1. Synchronous FIFO RTL (`rtl/fifo.sv`)
I wrote a parameterized synchronous FIFO supporting:
* Configurable depth, data width, and almost-full/almost-empty thresholds.
* Overflow and underflow protection flags (asserted for 1 cycle on illegal access).
* Combinational flag generation (`full`, `empty`, `almost_full`, `almost_empty`) and registered read/write pointers.

### 2. UVM Testbench Architecture (`tb/`)
I built a modular UVM environment from scratch:
* **Interface (`fifo_if.sv`)**: Defined clocking blocks with 1ns input/output skew for driver and monitor to avoid race conditions.
* **Transaction (`fifo_item.sv`)**: Modeled randomized write/read command inputs and outputs.
* **Driver (`fifo_driver.sv`)**: Synchronously drove transaction items onto the interface based on clocking blocks.
* **Monitor (`fifo_monitor.sv`)**: Sampled the interface. I implemented a pipelined sampling mechanism to align command inputs in cycle N with their updated outputs/flags in cycle N+1.
* **Scoreboard (`fifo_scoreboard.sv`)**: Modeled a golden reference using a SystemVerilog queue. It checks data integrity and ensures that all flags and overflow/underflow conditions match the DUT state.
* **Coverage Collector (`fifo_coverage.sv`)**: Tracks functional coverage on occupancy levels, transitions of empty/full flags, and simultaneous read/write operations.
* **Sequence Library (`fifo_seq_lib.sv`)**: Created test sequences covering:
  - Constrained-random reads/writes.
  - Simultaneous read and write access.
  - Write burst until full, and read burst until empty.
  - Mid-operation reset to verify correct state recovery.
* **Test Library (`fifo_test_lib.sv`)**: Implemented base, random, simultaneous, burst, and reset tests.

### 3. Assertions (SVA)
I wrote SystemVerilog Assertions in the interface to verify core protocol rules at the clock edge:
* `assert_overflow`: Verifies that writing to a full FIFO asserts the overflow flag next cycle.
* `assert_underflow`: Verifies that reading from an empty FIFO asserts the underflow flag next cycle.
* `assert_reset_state`: Ensures all pointers, flags, and outputs clear correctly when reset is active.
* `assert_full_empty_mutex`: Assures the FIFO is never full and empty simultaneously.
* `assert_rd_data_stable`: Verifies read data remains stable when no valid read occurs.

## Verification Results
All tests compile and pass successfully with zero UVM errors/fatals, zero assertion violations, and correct reference model tracking.

## How to Run

I added a `run.do` script inside the `tb` directory to automate compiling and running simulations in QuestaSim.

To run it, go to the `tb` directory and execute:
```bash
vsim -c -do run.do
```

Or if you are running it inside the Questa GUI, type this in the console:
```tcl
do run.do
```

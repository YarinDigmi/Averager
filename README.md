# Hardware Averaging Module (Verilog)

## Overview
This repository contains a robust RTL implementation of a data averaging engine. The module processes a stream of input data and calculates the average using a decoupled architecture consisting of an accumulator and an integer divider.

## Key Features
* **FSM-Based Control:** Uses a 4-state machine (PENDING, READY, WORKING, FINISH) for reliable data flow management.
* **Built-in Handshaking:** Supports `start`, `busy`, and `done` signals for easy integration into larger SoC designs.
* **Corner Case Handling:** Properly manages sequences where `data_first` and `data_last` occur simultaneously.
* **Resource Efficiency:** The divider unit is only triggered after the accumulation phase is complete to save dynamic power.
* **Safety Timeout:** Includes a `TO_count` mechanism to prevent the system from hanging in the `READY` state if data transmission fails.

## Architecture
The module is composed of three main parts:
1.  **Main FSM:** Manages the state transitions and control signals.
2.  **Summation Units:** Two instances of a `Sum` module – one for data accumulation and one for counting the number of samples.
3.  **Divider:** A `divu_int` instance that performs the final division `sum / count`.



## Interface Description

| Signal | Direction | Description |
| :--- | :--- | :--- |
| `clk` | Input | System Clock |
| `rst_n` | Input | Asynchronous Reset (Active Low) |
| `start` | Input | Starts the operation |
| `data_first` | Input | Marks the first sample of the batch |
| `data_last` | Input | Marks the last sample and triggers division |
| `data_in` | Input | Input data bus (Default: 32-bit) |
| `data_out` | Output | The calculated average (33-bit) |
| `busy` | Output | Asserted during calculation |
| `done` | Output | Asserted for one cycle when data_out is valid |
| `TO` | Output | Timeout flag |

## State Machine Logic
The FSM ensures that the divider only begins operation once the final data packet has been received and summed. The `negedge clk` trigger for `start_div` is used to prevent race conditions between the accumulator's `done` signal and the divider's `start` signal.





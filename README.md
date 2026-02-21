# Computer Architecture Lab (Spring 2026)
**EE/CE 321L / 330L / 371L**

Welcome to my repository for the Computer Architecture Lab at Habib University! This repository contains my complete progression of code, lab exercises, and the final project developed during the Spring 2026 semester for the BS Computer Science program.

The primary objective of this repository is to track my journey from writing software-level RISC-V assembly programs to the Register-Transfer-Level (RTL) hardware design and synthesis of a complete, working single-cycle RISC-V processor on an FPGA.

## 📚 Course Overview
Understanding the hardware that programs run on is critical for writing efficient code and innovating in an era where Moore's Law is slowing down. This course integrates theory and practice through a bottom-up learning philosophy:
1. **Assembly Language:** Understanding what instructions do.
2. **Digital Logic:** Understanding how hardware implements these instructions via datapath and control mechanisms.
3. **Hardware Synthesis:** Understanding why designs succeed or fail on real hardware through timing analysis, debugging, and physical constraints.

### Course Learning Outcomes (CLOs)
- **CLO 1:** Design and develop digital design modules of a RISC-V processor using Verilog HDL and simulate them.
- **CLO 2:** Utilize the RISC-V assembly instruction set for the implementation of case structures, loops, and functions.
- **CLO 3:** Design and synthesize a Single-Cycle RISC-V Processor on a Basys3 board.


## 🛠️ Tools & Technologies
* **Languages:** RISC-V Assembly (RV32I), Verilog HDL
* **Software:** Visual Studio Code (with Venus Simulator), Xilinx Vivado
* **Hardware:** Digilent Basys3 FPGA Board
* **Version Control:** Git & GitHub


## 🗂️ Repository Structure & Lab Sequence

The coursework is divided into two distinct phases, culminating in a final integrated hardware project.

### Phase I: RISC-V Assembly Language
*Focus: Arithmetic/logical instructions, memory access, branches, loops, and stack usage.*
* **Lab 1:** Getting Started with RISC-V in VS Code (Arithmetic operations)
* **Lab 2:** Implementing Decision Instructions (Control flow, branches, `beq`, `bne`)
* **Lab 3:** Implementing Jump and Return Instructions (Subroutines, `jal`, `jalr`)
* **Lab 4:** Implementing Nested Procedures and Sorting (Stack management, recursion, Bubble Sort)

### Phase II: Hardware Design and FPGA Synthesis
*Focus: Verilog HDL, combinational/sequential logic, Finite State Machines, and processor modules.*
* **Lab 5:** Designing FSM Using FPGA Switches and LEDs
* **Lab 6:** Design and FPGA Implementation of the ALU
* **Lab 7:** Design and FPGA Implementation of the 32x32 Register File
* **Lab 8:** Design and FPGA Implementation of Memory System with Address Decoding
* **Lab 9:** Design and FPGA Implementation of the Control Path
* **Lab 10:** State-Based Control Flow Using RISC-V Assembly (FSMs in assembly)
* **Lab 11 (Open Ended):** Integration and FPGA Implementation of a Single-Cycle RISC-V Processor

### 🚀 Final Project: Assembly-Level Execution on Hardware
The capstone project involves integrating RISC-V assembly language programming with the fully functional hardware processor designed in Lab 11. 
* Executing the assembly FSM (from Lab 10) directly on the physical processor.
* Extending the RV32I ISA by implementing and verifying three custom RISC-V instructions into the datapath.
* Demonstrating a creative assembly-level program (e.g., Fibonacci, Factorial) running on the Basys3 hardware with observable outputs.


## 📖 References & Materials
* **Textbook:** *Computer Organization and Design RISC-V Edition* by David A. Patterson & John L. Hennessy (Morgan Kaufmann, 2017)
* **Instructors:** Abeera Farooq Alam & Waseem Hassan

*Maintained by Shaheer Qureshi & Areeba Izhar.*

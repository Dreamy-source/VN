# VN (Vanilla) — Human-Oriented Processor Architecture
## Simple, Fast, Logic.

## Modules
### Core
- ALU (Arithmetic Logic Unit)
- DPU (Decode-Pipeline Unit)
### Memory
- MEM (Memory)
- MMU (Memory Management Unit)
- REG (Register File)
- STACK (Stack Controller)
### Peripheral
- GPIO (General-Purpose I/O)
#### Time
- COUNTER (Counter Controller)
- TIMER (Timer Controller)
### System
- INT (Interrupts Controller)
- RING (Ring Controller)

## Decode-Pipeline
- Stage 1: **IF**  — Fetch     |  Take instruction from memory
- Stage 2: **ID**  — Decode    |  Cut instruction to parts
- Stage 3: **EX**  — Execute   |  Perform calculations (ALU) and compute addresses
- Stage 4: **MEM** — Memory    |  Load from memory/Store to memory (Load/Store)
- Stage 5: **WB**  — Writeback |  Write results back to registers/memory

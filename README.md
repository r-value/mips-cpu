# mips-cpu
A 50 instructions 5-stage pipeline Harvard architecture MIPS CPU with full forwarding.

## Instructions

+ ALU: `ADD` / `ADDU` / `SUB` / `SUBU` / `SLL` / `SRL` / `SRA` / `SLLV` / `SRLV` / `SRAV` / `AND` / `OR` / `XOR` / `NOR` / `SLT` / `SLTU`
+ Load immediate: `LUI`
+ ALU w/ immediate: `ADDI` / `ADDIU` / `ANDI` / `ORI` / `XORI` / `SLTI` / `SLTIU`
+ MDU: `MULT` / `MULTU` / `DIV` / `DIVU` / `MFHI` / `MTHI` / `MFLO` / `MTLO`
+ Branch: `BEQ` / `BNE` / `BLEZ` / `BGTZ` / `BGEZ` / `BLTZ`
+ Jump: `JR` / `JALR` / `J` / `JAL`
+ Memory: `LB` / `LBU` / `LH` / `LHU` / `LW` / `SB` / `SH` / `SW`
+ `syscall`: stop simulation

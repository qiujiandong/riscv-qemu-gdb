.equ UART_H, 0x10000

.section .rodata
msg: .string "Hello RISC-V in Kernel Mode!\n"

.section .text
.global _start
_start: 
    la a0, msg
    lui a1, UART_H

while_loop:
    lb t0, 0(a0)
    beq t0, x0, end_while # if t0 == t1 then target
    sb t0, 0(a1)
    addi a0, a0, 1
    j while_loop

end_while:
    loop:
    j loop

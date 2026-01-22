.data
my_array: .space 20  
.text
.globl main
main:

    # 1. Load the base address of the array into x25
    la x25, my_array    

    li t0, 10           # Load 10 into temporary register t0
    sw t0, 0(x25)       # Store t0 at array[0] (offset 0)

    li t0, 10           # Load 10 into t0
    sw t0, 4(x25)       # Store t0 at array[1] (offset 4)

    li t0, 10           # Load 10 into t0
    sw t0, 8(x25)       # Store t0 at array[2] (offset 8)

    li t0, 25           # Load 25 into t0
    sw t0, 12(x25)      # Store t0 at array[3] (offset 12)

    li t0, 30           # Load 30 into t0
    sw t0, 16(x25)      # Store t0 at array[4] (offset 16)

    li x22, 0           # x22 (i) = 0 (Start index)
    li x24, 10          # x24 (k) = 10 (The value to skip)

Loop:
    slli x10, x22, 2    
    add x10, x10, x25  
    lw x9, 0(x10)     
    bne x9, x24, Exit  
    addi x22, x22, 1    
    beq x0, x0, Loop  # it is going 5 lines up so offset -20
Exit:
    j end               
end:
    j end
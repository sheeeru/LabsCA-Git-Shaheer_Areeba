.text
.globl main
main:
    li x25, 0x200
    li x23, 0

    li x22, 0

Loop1:
    li t0, 10
    bge x22, t0, End1   # if (i >= 10) break loop

    # Calculate Address of a[i]
    slli t1, x22, 2     # t1 = i * 4 (Byte offset)
    add t1, t1, x25     # t1 = Base Address + Offset (Address of a[i])

    # Store i into a[i]
    sw x22, 0(t1)       # Memory[t1] = i

    addi x22, x22, 1    # i++
    j Loop1             # Repeat

End1:

    # =================================================
    # LOOP 2: for (int i=0; i<10; i++) sum += a[i];
    # =================================================
    li x22, 0           # Reset i = 0 for the second loop

Loop2:
    li t0, 10
    bge x22, t0, End2   # if (i >= 10) break loop

    # Calculate Address of a[i]
    slli t1, x22, 2     # t1 = i * 4 (Byte offset)
    add t1, t1, x25     # t1 = Base Address + Offset

    # Load a[i] and Add to Sum
    lw t2, 0(t1)        # t2 = a[i] (Load value from memory)
    add x23, x23, t2    # sum = sum + t2

    addi x22, x22, 1    # i++
    j Loop2             # Repeat

End2:
    # End of program
    j end

end:
    j end
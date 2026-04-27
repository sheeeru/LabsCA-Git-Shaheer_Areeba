# taskb.s
# Task B - Instruction Extension verification
# Demonstrates 3 custom instructions: LUI, BNE, JAL
# Writes the full 32-bit result to the 7-segment display (upper 16) and LEDs (lower 16).

main:
    addi x30, x0, 768    # 1. x30 = Switch address (0x300)
    addi x31, x0, 512    # 2. x31 = LED/7-Seg address (0x200)

    # 1st Custom Instruction: LUI
    # We load 0x12345000 into x5. The upper 16 bits are 0x1234.
    lui x5, 0x12345      # 3. x5 = 0x12345000

    # To show we can use JAL, jump to the loop_setup
    jal ra, loop_setup   # 4. Jump to loop_setup
    
display:
    # 9. Output x6 to MMIO (32-bit). 
    # 7-Segment will show "1234", LEDs will show "0000000000001111"
    sw x6, 0(x31)        
end:
    beq x0, x0, end      # Infinite loop

loop_setup:
    # Construct our final 32-bit value in x6. 
    add x6, x0, x5       # x6 = 0x12345000

    # Let's use a BNE loop to add 0x00000001 until we reach 15.
    add x7, x0, x0       # x7 = 0 (counter)
    addi x8, x0, 15      # x8 = 15 (limit)

loop:
    addi x6, x6, 1       # Increment lower bits of x6
    addi x7, x7, 1       # Increment counter
    
    # 2nd Custom Instruction: BNE
    bne x7, x8, loop     # if (x7 != 15) goto loop

    # Return to display using JALR
    jalr x0, 0(ra)       # Return to caller

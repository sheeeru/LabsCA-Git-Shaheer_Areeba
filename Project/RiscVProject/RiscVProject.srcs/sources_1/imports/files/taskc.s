# taskc.s
# Task C - Custom Program (Summation of an arithmetic sequence)
# MUST USE: LUI, JAL, BNE (from Task B requirements)
# Reads switch input N. If N != 0, computes Sum = N + (N-1) + ... + 1.
# Outputs the Sum to the LEDs (lower 16) and a LUI value to the 7-segment (upper 16).

main:
    # 1. Setup MMIO Addresses
    addi x30, x0, 768          # Switch Address (0x300)
    addi x31, x0, 512          # LED/7-Seg Address (0x200)

read_input:
    # 2. Wait for user to input a number
    lw x5, 0(x30)              # Read N from switches
    beq x5, x0, read_input     # If N is 0, wait

    add x6, x0, x0             # x6 will hold our SUM. Start at 0.
    add x7, x0, x5             # x7 is our COUNTER. Start at N.

sum_loop:
    # 3. Add counter to sum using a Subroutine! [Uses JAL]
    jal ra, add_subroutine     
    
    # 4. Decrement counter and loop
    addi x7, x7, -1            # COUNTER = COUNTER - 1
    bne x7, x0, sum_loop       # If COUNTER is not 0, loop back [Uses BNE]

display:
    # 5. Output the result and verify LUI
    # We will load 0x000AA000 into x8 [Uses LUI]
    # This will display "00AA" on the 7-segment display!
    lui x8, 0x000AA            
    
    # Add the LUI value to our sum
    add x6, x6, x8             
    
    # Write to MMIO (Lower 16 bits -> LEDs, Upper 16 bits -> 7-Segment)
    sw x6, 0(x31)              
    
    # Loop back to start
    beq x0, x0, read_input     

add_subroutine:
    # Addition logic inside subroutine
    add x6, x6, x7             # SUM = SUM + COUNTER
    jalr x0, 0(ra)             # Return from subroutine

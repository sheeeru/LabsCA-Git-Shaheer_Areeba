.text
.globl main
main:
    addi x10, x0, 0x100     

    # ID 3 = Spectre, ID 2 = Sheriff, ID 1 = Classic
    # a[0] = 3 (Spectre)
    addi x5, x0, 3    
    sw x5, 0(x10)          
    # a[1] = 3 (Spectre)
    addi x5, x0, 3
    sw x5, 4(x10)         
    # a[2] = 2 (Sheriff)
    addi x5, x0, 2
    sw x5, 8(x10)           
    # a[3] = 1 (Classic)
    addi x5, x0, 1
    sw x5, 12(x10)       
    # a[4] = 3 (Spectre)
    addi x5, x0, 3
    sw x5, 16(x10)         

    addi x11, x0, 5 # Argument a1: Count = 5 players
    jal x1, calc_team_value 

    addi x11, x10, 0    
    li x10, 1 
    ecall
    j exit

# "Non-Leaf Procedure" (The Manager)
# Loops through array. Calls 'get_price' for each item.
calc_team_value:
    addi sp, sp, -16
    sw x1, 8(sp) # Save Return Address
    sw s0, 4(sp) # Save s0 Array Pointer
    sw s1, 0(sp) # Save s1 Total Value
    sw s2, 12(sp) # Save s2 Counter

    # We move arguments to 's' registers. The Callee (get_price) 
    addi s0, x10, 0 # s0 = Array Pointer (Copy from a0)
    addi s1, x0, 0 # s1 = Total Value (Initialize to 0)
    addi s2, x11, 0 # s2 = Counter (Copy from a1)

Loop:
    beq s2, x0, EndLoop  # If Counter == 0, exit loop

    lw x10, 0(s0) # Load Weapon ID from memory into Argument x10
    
    jal x1, get_price # Call the child. x1 is overwritten here!
    # (Result comes back in x10)

    add s1, s1, x10 # Total += Price

    addi s0, s0, 4 # Move Pointer to next word (4 bytes)
    addi s2, s2, -1 # Decrement Counter
    j Loop # Jump back to start

EndLoop:
    # Return Value: Move Total (s1) to Result Register (x10/a0)
    addi x10, s1, 0         

    lw s1, 0(sp) # Restore s1
    lw s0, 4(sp) # Restore s0
    lw x1, 8(sp) # Restore Return Address
    lw s2, 12(sp) # Restore s2
    addi sp, sp, 16
    
    jalr x0, 0(x1)

# Takes ID, returns Price. Calls NO other functions.
# NO STACK NEEDED because it's a leaf.
get_price:
    addi t0, x0, 3 
    beq x10, t0, IsSpectre   # If ID == 3, goto Spectre

    addi t0, x0, 2  
    beq x10, t0, IsSheriff  # If ID == 2, goto Sheriff
    
    # Default (Classic)
    addi x10, x0, 0         # Price = 0
    jalr x0, 0(x1)          # Return

IsSheriff:
    addi x10, x0, 800 # Price = 800
    jalr x0, 0(x1)   

IsSpectre:
    addi x10, x0, 1600 # Price = 1600
    jalr x0, 0(x1)  

end: 
    j end
exit:
    j end
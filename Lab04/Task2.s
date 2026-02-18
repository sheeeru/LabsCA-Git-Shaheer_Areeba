.text
.globl main
main:
    li x10, 6 #term to sum till #ans =21
    jal x1, ntri #jump to ntri 
    addi x11, x10,0 #store answer in x11
    li x10, 1
    ecall
    j exit

ntri:
    li x5, 1
    ble x10, x5, end_ntri
    addi sp, sp, -8
    sw x1, 4(sp) #store address on stack
    sw x10, 0(sp) #store n on stack

    addi x10, x10, -1 #decrement x10 by 1
    jal x1, ntri #recursive call to ntri
    lw x5, 0(sp) #restore address from stack
    lw x1, 4(sp) #restore n from stack
    addi sp, sp, 8 #restore stack pointer

    add x10, x10, x5#add n to answer from recursive call
    jalr x0, 0(x1) #return from ntri

end_ntri:
    li x10, 1 #base case return 1
    jalr x0, 0(x1) #return from ntri

end:
    j end

exit:
    j end

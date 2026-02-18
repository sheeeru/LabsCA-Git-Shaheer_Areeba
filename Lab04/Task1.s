.text
.globl main
main:
    li x6, 1 #answer 
    li x10, 5 #n (120)
    jal x1, loop #jump to loop 
    addi x11, x10,0
    li x10, 1
    ecall
    j exit

loop:
    li x5, 1 #1 to compare with the blt statement (if n<= 1)
    blt x10, x5, end_loop
    mul x6, x6, x10 #n- n*(n-1)
    addi x10, x10, -1 #decrement n
    j loop

end_loop:
    addi x10, x6, 0 #store answer in x10
    jalr x0, 0(x1) #return from main

end:
    j end

exit:
    j end


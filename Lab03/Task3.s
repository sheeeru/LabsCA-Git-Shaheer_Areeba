.data
arr: .word 5, 10, 15, 20, 25
.text
.globl main
main:
    la x10, arr #arr parameter 1
    li x11, 2 #k parameter 2

    jal x1, swap
    la x10, arr 
    lw x11, 12(x10) 
    li x10, 1
    ecall
    j exit

swap:
    li x20, 4
    mul x6, x11, x20  #calculate offset k*4 [slli x6, x11, 2]
    add x6, x10, x6

    #temp var
    lw x5, 0(x6)
    lw x7, 4(x6)
    sw x7, 0(x6)
    sw x5, 4(x6)

    jalr x0, 0(x1)

exit:
    j end
end:
    j end
    

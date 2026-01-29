.text
.globl main
main:
    li x5, 0x100
    li x6, 10
    sw x6, 0(x5) # 0 at address 0x100
    li x6, 20
    sw x6, 4(x5)
    li x6, 30
    sw x6, 8(x5) 
    li x6, 40
    sw x6, 12(x5)
    li x6, 50
    sw x6, 16(x5)  # 50 at address 0x10C
    li x10, 0x100
    li x11, 2 #k parameter 2

    jal x1, swap
    li x10, 0x100
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
    

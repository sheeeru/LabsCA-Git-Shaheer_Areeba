.text
.globl main
main:
    li x5, 0x200
    li x6, 's'
    sb x6, 0(x5) # 's' at address 0x200
    li x6, 'h'
    sb x6, 1(x5)
    li x6, 'a'
    sb x6, 2(x5) 
    li x6, 'h'
    sb x6, 3(x5)
    li x6, 'e'
    sb x6, 4(x5)
    li x6, 'e'
    sb x6, 5(x5)
    li x6, 'r'
    sb x6, 6(x5)
    li x6, 0
    sb x6, 7(x5)  #null

    li x10, 0x100
    li x11, 0x200

    jal x1, strcpy
    j exit

strcpy:
    addi sp, sp, -4 #create stack space
    sw x19, 0(x2) #i 
    li x19, 0

loop1:
    add x5, x19, x11 #get y[i] 
    lb x6, 0(x5)     #load y[i]
    add x7, x19, x10 #get x[i]
    sb x6, 0(x7)     #store in x[i]

    beq x6, x0, endloop #if y[i] == null, end loop

    addi x19, x19, 1 #i++
    j loop1
endloop:
    lw x19, 0(x2)
    addi x2, x2, 4 #empty stack
    jalr x0, 0(x1) #return to caller

exit:
    j end

end:
    j end


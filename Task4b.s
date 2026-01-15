.text
.globl main
main:
    li x10, 0x100
    li x11, 0x200
    li x12, 0x300
    #array a
    li x5, 2           
    sb x5, 0(x10)  #byte at 0x100 a[0]
    li x5, 3
    sb x5, 1(x10)       
    li x5, 4
    sb x5, 2(x10)     
    li x5, 5
    sb x5, 3(x10)
    #array b
    li x5, 10
    sh x5, 0(x11)  #store byte at 0x200 b[0]
    li x5, 20
    sh x5, 2(x11)       
    li x5, 30
    sh x5, 4(x11)      
    li x5, 40
    sh x5, 6(x11)
    #array a iteration 1
    lb x13, 0(x10) #character array (1 byte)
    lh x14, 0(x11) #short array (2 bytes)
    add x15, x13,x14
    sw x15, 0(x12) # int array (4 bytes)
    #array a iteration 2
    lb x16, 1(x10)
    lh x17, 2(x11)
    add x18, x16,x17
    sw x18, 4(x12)
    #array a iteration 3
    lb x19, 2(x10)
    lh x20, 4(x11)
    add x21, x19,x20
    sw x21, 8(x12)
    #array a iteration 4
    lb x22, 3(x10)
    lh x23, 6(x11)
    add x24, x22,x23
    sw x24, 12(x12)
end:
    j end
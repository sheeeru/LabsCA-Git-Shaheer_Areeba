# long long int leaf_example (long long int g, long long int h, long long int i, long long int j)
# {
# long long int f;
# f = (g+ h) - (i + j);
# return f;
# }

.text
.globl main
main:
    li x10, 5          #g
    li x11, 4          #h
    li x12, 3         #i
    li x13, 2

    jal x1, leaf_example
    addi x11, x10, 0 #ecall always prints x11
    li x10, 1
    ecall
    j exit 

leaf_example:
    addi x2,x2, -24 #assign stack
    sd x18, 0(x2)
    sd x19, 8(x2)
    sd x20, 16(x2)

    add x18, x10, x11    #temp1 = g + h
    add x19, x12, x13    #temp2 = i + j
    sub x20, x18, x19   #f = temp1 - temp2

    addi x10, x20, 0 #return f


    ld x18, 0(x2)
    ld x19, 8(x2)
    ld x20, 16(x2)
    addi x2, x2, 24 #free space for stack
    jalr x0, 0(x1)

exit:
    j end
end:
    j end

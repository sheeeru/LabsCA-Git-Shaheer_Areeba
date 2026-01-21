.text
.globl main
main:
    li x1, 5 #a
    li x2, 0 #b
    addi x1, x2, 32 #a=b+32
    add x4, x1, x2 #a+b
    addi x5, x4, -5 #d=(a+b)-5
    sub x6, x1, x5 #(a-d)
    sub x7, x2, x1 # b-a
    add x8, x6, x7 #(a-d)+(b-a)
    add x9, x8, x5 #e = x8 + d
    add x10, x5, x9
    add x9, x4, x10

end:
    j end


    

    

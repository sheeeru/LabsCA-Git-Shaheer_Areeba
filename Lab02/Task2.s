.text
.globl main
main:
    #valyes for a b c and x
    li x21, 0 #a
    li x22, 20          #b = 20
    li x23, 10          #c = 10
    li x20, 4           #x = 1 or 2 or 3 or 4

    li x6, 1 #if x ==1
    li x7, 2 #if x==2
    li x28, 3 #if x==3
    li x29, 4 #if x==4
    li x5, 0 #default case 
    li x30, 2 # temp var for division and multi

    beq x20, x6, Case1
    beq x20, x7, Case2
    beq x20, x28, Case3
    beq x20, x29, Case4
    beq x0, x0, Default

Case1:
    add x21, x22, x23
    j end

Case2:
    sub x21, x22, x23
    j end

Case3:
    mul x21, x22, x30
    j end

Case4:
    div x21, x22, x30
    j end  

Default:
    li x21, 0
    j end

end:
    j end
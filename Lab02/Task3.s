.text
.globl main
main:
    li x22, 0 #i=0
    li x23, 0 #sum=0
    li x5, 0x200 #array address
    li x6, 10 #size of loop =10

loop:
    bge x22, x6, exit #if i>=10 exit loop
    slli x7, x22, 2   #jump by 2^2 =4
    add x7, x7, x5 #address of array[i] in x7
    lw x8, 0(x7) #load array[i] in x8
    add x23, x23, x8 #sum = sum + array[i]
    addi x22, x22, 1 #i++
    j loop

exit:
    j end
    
end:
    j end
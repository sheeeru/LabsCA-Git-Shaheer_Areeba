.text
.globl main
main:
    li x5, 3 #a -> test val
    li x6, 4 #b -> assumed base vals for testing
    li x7, 0 #i
    li x10, 0x200 #array base address (random)

loopouter:
    bge x7, x5, exit #end program
    li x29, 0 # j will reset everytime i loop 1 iteration end

loopinner:
    bge x29, x6, endinner #if j>=b end inner loop

    slli x28, x29, 4 #x28= j*4 (2^4)
    add x28, x28, x10 #x28 = address of D[4*j] 

    add x30, x7, x29 #x30 = i + j
    sw x30, 0(x28) #D[4*j] = i + j 

    addi x29, x29, 1 #j++
    j loopinner

endinner:
    addi x7, x7, 1 #i++
    j loopouter

exit:
    j end

end:
    j end

 #first defined the outer loop condition on when it would fail. 
 #when it won't so it would enter j loops (means j value will reset everytime i increments)
 #then i defined inner loop with its failign condition first
 #since its j*4 it will just 2^4 times (shift left) j to get the address of D[4*j]
 #then add i+j, store in D[4*j] and increment j.
 #ending inner loop condition would be with an increment and loop outer back (until it eventuall reaches fail condiution)
 
 

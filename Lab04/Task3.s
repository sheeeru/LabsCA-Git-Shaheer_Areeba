.text
.globl main
main:
    li x10, 0x100 #base add for array
    li x6, 50
    sw x6, 0(x10) 
    li x6, 40
    sw x6, 4(x10)
    li x6, 30
    sw x6, 8(x10) 
    li x6, 20
    sw x6, 12(x10)
    li x6, 10
    sw x6, 16(x10)  
    li x11, 5 #len
    jal x1, bubble

bubble:
    beq x11, x0, escape #if len is 0 return
    beq x10, x0, escape #if base add is 0
    li x5, 0 #i

outer_loop:
    beq x5, x11, escape #if i ==len so end loop
    addi x6, x5, 0 #j==i

inner_loop:
    beq x6, x11, end_outer #if j == len so end loop
    slli x29, x5, 2 #i*4
    add x29, x29, x10 #base add + i*4 
    slli x30, x6, 2 #j*4
    add x30, x30, x10 #base add + j*4
    lw x7, 0(x29) #load a[i] in the same
    lw x28, 0(x30) #load a[j] in the same 
    ble x7, x28, skip #if a[j] < a[i] 
    sw x28, 0(x29) #swap a[i] and a[j]
    sw x7, 0(x30)

end_outer: 
    addi x5, x5, 1 #increment i
    j outer_loop

escape:
    jalr x0, 0(x1)

skip:
    addi x6, x6, 1 #increment i
    j inner_loop

end:
    j end

exit:
    j end
  
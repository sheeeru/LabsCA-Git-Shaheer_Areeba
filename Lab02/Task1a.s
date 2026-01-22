# beq x5, x6, label -> opcode, then binary codes for registers, bits for the distance (contain a statement)
.text
.globl main
main:
    li x22, 10          # i = 0
    li x23, 10         # j = 10
    li x20, 5          # g = 5
    li x21, 3          # h = 3
    li x19, 0          # f = 0
Loop:
    bne x22, x23, Else # if (i==j): f= g+h  | Else f= g-h
    add x19, x20, x21
    beq x0, x0, Exit

Else:
    sub x19, x20, x21
Exit:
    j end

end:
    j end
    
# exit and end are outside the loop bz they are the steps that define 
#what the count is to cause the jump. 
#main has the f else condition only

# ctrl+shift + P: assemble and run 
# in assember take the middle hex value, convert to binary, use the table in RISC=V greencard reference to distrubite the bits. 
# cross check values for the imm[12|10:5] and imm[4:1|11] with the binary value to get the value for the distance.


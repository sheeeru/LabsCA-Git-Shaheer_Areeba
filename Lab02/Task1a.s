# beq x5, x6, label -> opcode, then binary codes for registers, bits for the distance (contain a statement)
.text
.globl main
main:
    bne x22, x23, Else # if (i==j): f= g+h  | Else f= g-h
    add x19, x20, x21
    beq x0, x0, Exit

Else:
    sub x19, x20, x21
Exit:
    j end
    
# exit and end are outside the loop bz they are the steps that define 
#what the count is to cause the jump. 
#main has the f else condition only
.text
.globl main
main:
    li x10, 0x78786464
    li x11, 0xA8A81919

    # We need to load the memory addresses into temporary registers first

    #1 sw (Store Word) : stores 4 bytes

    li x5, 0x100 #this is the first indx of the array which is the add of the arr
    sw x10, 0(x5) #which is why 0 is written bcz 1st indx is the address

    #2
    li x6, 0x1F0 
    sw x11, 0(x6)

    #3 Load unsigned short from 0x100 to x12 --- lhu (Load Halfword Unsigned) -> Loads 2 bytes
    lhu x12, 0(x5)

    #4 Load short from 0x1F0 to x13 --- lh (Load Halfword Signed) -> Loads 2 bytes
    lh x13, 0(x6)

    #5 Load signed char from 0x1F0 to x14 --- lb (Load Byte Signed) -> Loads 1 byte
    lb x14, 0(x6)

end:
    j end
addi x10,x0,20
jal x1,sum
jal x0,end
sum:addi sp, sp, -8
    sw x1, 4(sp)
    sw x10, 0(sp)
addi   x5, x10, -2
bge    x5, x0, L1  
addi   x10, x0, 1
addi   sp, sp, 8
jalr   x0, 0(x1)
L1: addi x10, x10, -1 
 	jal x1, sum 
addi 	x6, x10, 0 	
lw 	 x10, 0(sp) 
lw 	 x1, 4(sp)
addi 	sp, sp, 8
add    x10, x10, x6 
jalr   x0, 0(x1) 
end:

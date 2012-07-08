.data
item :
.word 5,3,5,2,13

.text 
.globl main


main:
addi $2,$0,5
addi $3,$0,14
addi $5,$0,19
addi $6,$0,-9
addi $7,$0,3
addi $8,$0,20
addi $9,$0,2
addi $10,$0,16
addi $11,$0,30
addi $12,$0,-31
addi $13,$0,-3
addi $14,$0,1
beq $2,$2,next1
next1:
bne $2,$3,next2
next2:
la $4,next
jr $4


error:
add $22,$3,$3
nor $2,$0,$0
sll $2,$2,6
la $3, 0x40000010
sw $2, ($3)
j finish

next:
la $4,lastnext
test:
jalr $4
finderror:
j error

lastnext:
la $4,finderror
bne $4,$31,error
jal testlast

finderror2:
j error

testlast:
la $4 finderror2
bne $4,$31,error
beq $3,$2,error
bne $2,$2,error
add $4,$2,$3
bne $4,$5,error
sub $4,$2,$3
bne $4,$6,error
srlv $4,$3,$9
bne $4,$7,error
srl $4,$3,2
bne $4,$7,error
srav $4,$6,$9
bne $4,$13,error
sra $4,$6,2 
bne $4,$13,error
sllv $4,$2,$9
bne $4,$8,error
sll $4,$2,2
bne $4,$8,error
and $4,$5,$8
bne $4,$10,error
andi $4,$5,20
bne $4,$10,error
ori $4,$3,20
bne $4,$11,error
or $4,$3,$8
bne $4,$11,error
nor $4,$3,$8
bne $4,$12,error
slti $4,$3,19
bne $4,$14,error
slti $4,$5,2
bne $4,$0,error
slt $4,$5,$3
bne $4,$0,error
slt $4,$3,$5
bne $4,$14,error
la $18,item
lw $0,0($18)
sw $4,0($18)
lw $16,0($18)
beq $16,$4,end

finish:
add $25,$2,$2
LOOP1:
add $25,$0,$25
j LOOP1

end:
add $22,$3,$3
nor $2,$0,$0
srl $2,$2,28
la $3, 0x40000010
sw $2, ($3)
j LOOP1


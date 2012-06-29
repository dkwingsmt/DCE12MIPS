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
beq $2,$2,next

error:
j finish


next:
bne $2,$2,error
add $4,$2,$3
bne $4,$5,error
sub $4,$2,$3
bne $4,$6,error
srl $4,$3,2
bne $4,$7,error
sra $4,$6,2 
bne $4,$13,error
sll $4,$2,2
bne $4,$8,error
and $4,$5,$8
bne $4,$10,error
or $4,$3,$8
bne $4,$11,error
nor $4,$3,$8
bne $4,$12,error
slt $4,$3,$5
bne $4,$14,error
la $18,item
lw $0,0($18)
sw $4,0($18)
lw $16,0($18)
beq $16,$4,end

finish:
add $25,$2,$2
LOOP1:add $25,$0,$25
j LOOP1

end:
add $22,$3,$3
j LOOP1


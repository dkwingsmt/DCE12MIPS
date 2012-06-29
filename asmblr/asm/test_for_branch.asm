.data
item:
.word 1,2,3,4,5

.text
.globl main

main:
addi $2,$0,11
addi $3,$0,11
beq $2,$3,test
addi $4,$0,2


test:
addi $4,$0,5


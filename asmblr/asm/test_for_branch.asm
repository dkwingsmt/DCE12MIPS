.data
item:
.word 1,2,3,4,5

.text
.globl main

main:
addi $1,$0,11
addi $2,$0,11
beq $1,$2,test
addi $3,$0,2


test:
addi $3,$0,5


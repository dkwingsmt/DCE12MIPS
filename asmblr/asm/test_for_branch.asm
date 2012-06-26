.data
item:
.word 1,2,3,4,5

.text
.globl main

main:
addi $t1,$0,11
addi $t2,$0,11
beq $t1,$t2,test
addi $v1,$0,2


test:
addi $v1,$0,5


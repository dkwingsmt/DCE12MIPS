.data
led:
.word   0x40,
	0x79,
	0x24,
	0x30,
	0x19,
	0x12,
	0x02,
	0x78,
	0x00,
	0x10,
	0x06, #e 
	0x27, #c 0100111
	0x12, #s
	0x63, #u 1100011
	0x2f, #r 0101111
anx_indicator :
.word 0
led_show:
.word 0,0,0,0
	
.text
.globl main


main:
la $s3,anx_indicator
li $s0,0x40000008
addi $s1,$0,0xfffffff0
sw $s1,0($s0) 
addi $s1,$0,0xfffff7ff
sw $s1,-8($s0)
addi $s1,$0,0xfffffff3
sw $s1,0($s0) 
li $s0,0x40000010
lw $a0,($s0)
lw $a1,4($s0)
#addi $a0,$0,94248
#addi $a1,$0,48552
loop:
slt $t0,$a0,$a1
beqz $t0,jumpswap
move $t1,$a0
move $a0,$a1
move $a1,$t1
jumpswap:
sub $t0,$a0,$a1
beq $t0,$a1,finish
move $a0,$t0
j loop

finish:
move $v0,$a1
addi $t0,$0,1000
move $t1,$0
loop1000:
slt $t2,$v0,$t0
bne $t2,$0,next100
sub $v0,$v0,$t0
addi $t1,$t1,1
j loop1000

next100:
la $t0,led
sll $t1,$t1,2
add $t0,$t0,$t1
lw $t1,0($t0)
sll $t1,$t1,4
addi $t1,$t1,7
la $t0,led_show
sw $t1,0($t0)

addi $t0,$0,100
move $t1,$0
loop100:
slt $t2,$v0,$t0
bne $t2,$0,next10
sub $v0,$v0,$t0
addi $t1,$t1,1
j loop100

next10:
la $t0,led
sll $t1,$t1,2
add $t0,$t0,$t1
lw $t1,0($t0)
sll $t1,$t1,4
addi $t1,$t1,0xb
la $t0,led_show
sw $t1,4($t0)

addi $t0,$0,10
move $t1,$0
loop10:
slt $t2,$v0,$t0
bne $t2,$0,next1
sub $v0,$v0,$t0
addi $t1,$t1,1
j loop10

next1:
la $t0,led
sll $t1,$t1,2
add $t0,$t0,$t1
lw $t1,0($t0)
sll $t1,$t1,4
addi $t1,$t1,0xd
la $t0,led_show
sw $t1,12($t0)
la $t0,led
sll $v0,$v0,2
add $t0,$t0,$v0
lw $t1,0($t0)
sll $t1,$t1,4
addi $t1,$t1,0xe
la $t0,led_show
sw $t1,16($t0)

j main


interrupt:
j start

start:
li $s0,0x40000008
addi $s1,$0,0xfffffff9
sw $s1,0($s0) # finish tcon


lw $s1,0($s3)
la $s2,led_show
sll $s5,$s1,2
add $s2,$s2,$s5
lw $s1,0($s2)
li $s4,0x40000018
sw $s1,0($s4)
addi $s1,$s1,1
addi $s5,$0,4
slt $s5,$s1,$s5
bne $s5,$0,nextdd
addi $s1,$0,0
nextdd:
sw $s1,0($s3)

addi $s1,$0,0x00000003
sw $s1,0($s0)
jr $26


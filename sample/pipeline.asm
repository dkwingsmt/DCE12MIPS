.text 0x410000
.align 4
.globl main
.globl L1
.globl L2
main:
       j  L0
illop: j  Badop
xp:    j  isr       
Error: j Error
OK:    j OK	 
L0:   add $0 , $0 , $0 
   addi $10 , $0 , 1   # $10=1
   add  $2 , $10 , $10 # $2 = 2并且有一个RAW竞争
   add  $3 , $2 , $10  # $3 = 3有一个RAW竞争，且和前面两条指令关联
   add  $4 , $3 , $10  # $4=4，这时$10应该已经写进去了，
   add  $5 , $4 , $10  # RAW竞争
   add  $6 , $5 , $10  # RAW竞争
   add  $7 , $6 , $10 # RAW竞争
	 addi $8 , $0 , 1   
	 sll  $8 , $8 , 28  # RAW竞争$8
	 sw   $8 , 512($8)  # sw指令和sll的$8关联
	 lw   $9 , 512($8)  # lw指令和sll的$8关联
	 add  $11 , $9 , $0 # $11 = 0x10000000
	 add  $12 , $9 , $11  # $12 = 0x20000000
	 beq  $11 ,  $9 , L1  # $11应该等于$9，而且这里有一个RAW关联（$11的）
	 add  $8 , $8 , $8  #should not execute this
	 add  $0 , $0 , $0
	 add  $0 , $0 , $0
	 j    Error
L1:bne  $8 ,  $12 , L2 #$8不应该等于$12，
   j    Error
L2:bgezal $8 , L3     # lower address  0x68
	 addi  $ra , $0, 1  #这条指令应该被取消
	 addi  $ra , $0, 1  #这条指令应该被取消
	 j    Error
L3:add  $20 , $ra, $ra  #
   andi $20 , $ra , 0x0FFF	 # should be 0x6C
   addi $21 , $0 , 0x6C
   bne  $20 , $21, Error   # 判断前面的bgezal是否正确保存了返回地址
   lui  $13,  0x8041
   addi $13 , $13 , 0x94   #address 0x94
   jal  L4
L4:bne  $ra , $13 , Error  # 判断jal指令是否正确保存了返回地址0x80410094
	 lw   $14 , 512($8)    
	 sw   $14 , 516($8)      #sw after lw，关联
	 lw   $15 , 516($8)      # lw after sw，
	 bne  $14 , $15 , Error  #应该相等
	 jal  L5
L5:sll  $ra , $ra , 1
	 srl  $ra , $ra , 1 #remove the supervisor bit
	 addi $ra , $ra , 0x10
	 jr   $ra           #jump to next inst (should be forwarded to ID stage)$ra和前面两条指令关联
	 bne  $3 , $3 , Error #继续执行
	 bne  $4 , $4 , Error #继续执行
	 bne  $5 , $5 , Error #继续执行
	 add  $4 , $0 , $0   
	 addi $4 , $4 ,1   # $4 = 1 IRQ here 此处发生中断，将得到响应（前面有一个中断不应该被响应）
	 bne  $6 , $6 , Error
	 bne  $7 , $7 , Error
	 bne  $4 , $6 , Error # after Isr , $4 should be 6
	 .word 0xFFFFFFFF     #Badop
	 add  $26, $26 , $0 
	 bne  $4 , $7 , Error #这时应该等于$7
	 add  $26, $0 , $0 
	 add  $26, $0 , $0 
	 add  $26, $0 , $0 	 
	 j    OK              #  检查OK，恭喜！
Badop:add $4 , $0 , $7 
      jr   $26
isr:  add  $0 , $0, $0 
 			add  $0 , $0, $0 
 			add  $0 , $0, $0 
      add  $4 , $4 , $5     # should equal to 5
      beq  $4 , $6 , Error  
      addi $26 , $26 , -4 
      jr   $26
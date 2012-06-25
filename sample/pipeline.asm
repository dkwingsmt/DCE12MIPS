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
   add  $2 , $10 , $10 # $2 = 2������һ��RAW����
   add  $3 , $2 , $10  # $3 = 3��һ��RAW�������Һ�ǰ������ָ�����
   add  $4 , $3 , $10  # $4=4����ʱ$10Ӧ���Ѿ�д��ȥ�ˣ�
   add  $5 , $4 , $10  # RAW����
   add  $6 , $5 , $10  # RAW����
   add  $7 , $6 , $10 # RAW����
	 addi $8 , $0 , 1   
	 sll  $8 , $8 , 28  # RAW����$8
	 sw   $8 , 512($8)  # swָ���sll��$8����
	 lw   $9 , 512($8)  # lwָ���sll��$8����
	 add  $11 , $9 , $0 # $11 = 0x10000000
	 add  $12 , $9 , $11  # $12 = 0x20000000
	 beq  $11 ,  $9 , L1  # $11Ӧ�õ���$9������������һ��RAW������$11�ģ�
	 add  $8 , $8 , $8  #should not execute this
	 add  $0 , $0 , $0
	 add  $0 , $0 , $0
	 j    Error
L1:bne  $8 ,  $12 , L2 #$8��Ӧ�õ���$12��
   j    Error
L2:bgezal $8 , L3     # lower address  0x68
	 addi  $ra , $0, 1  #����ָ��Ӧ�ñ�ȡ��
	 addi  $ra , $0, 1  #����ָ��Ӧ�ñ�ȡ��
	 j    Error
L3:add  $20 , $ra, $ra  #
   andi $20 , $ra , 0x0FFF	 # should be 0x6C
   addi $21 , $0 , 0x6C
   bne  $20 , $21, Error   # �ж�ǰ���bgezal�Ƿ���ȷ�����˷��ص�ַ
   lui  $13,  0x8041
   addi $13 , $13 , 0x94   #address 0x94
   jal  L4
L4:bne  $ra , $13 , Error  # �ж�jalָ���Ƿ���ȷ�����˷��ص�ַ0x80410094
	 lw   $14 , 512($8)    
	 sw   $14 , 516($8)      #sw after lw������
	 lw   $15 , 516($8)      # lw after sw��
	 bne  $14 , $15 , Error  #Ӧ�����
	 jal  L5
L5:sll  $ra , $ra , 1
	 srl  $ra , $ra , 1 #remove the supervisor bit
	 addi $ra , $ra , 0x10
	 jr   $ra           #jump to next inst (should be forwarded to ID stage)$ra��ǰ������ָ�����
	 bne  $3 , $3 , Error #����ִ��
	 bne  $4 , $4 , Error #����ִ��
	 bne  $5 , $5 , Error #����ִ��
	 add  $4 , $0 , $0   
	 addi $4 , $4 ,1   # $4 = 1 IRQ here �˴������жϣ����õ���Ӧ��ǰ����һ���жϲ�Ӧ�ñ���Ӧ��
	 bne  $6 , $6 , Error
	 bne  $7 , $7 , Error
	 bne  $4 , $6 , Error # after Isr , $4 should be 6
	 .word 0xFFFFFFFF     #Badop
	 add  $26, $26 , $0 
	 bne  $4 , $7 , Error #��ʱӦ�õ���$7
	 add  $26, $0 , $0 
	 add  $26, $0 , $0 
	 add  $26, $0 , $0 	 
	 j    OK              #  ���OK����ϲ��
Badop:add $4 , $0 , $7 
      jr   $26
isr:  add  $0 , $0, $0 
 			add  $0 , $0, $0 
 			add  $0 , $0, $0 
      add  $4 , $4 , $5     # should equal to 5
      beq  $4 , $6 , Error  
      addi $26 , $26 , -4 
      jr   $26
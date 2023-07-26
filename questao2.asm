.data
MMIO_INPUT:  .word   0xffff000c  # Endereço de entrada MMIO
MMIO_OUTPUT: .word 0xffff0004  # Endereço de saida MMIO
BACKSPACE_KEY: .word 0x00000008         # Valor do caractere "backspace" (ascii 8)


.text
	lui	$t0,0xffff	#ffff0000
waitloop:
	lw	$t1,0($t0)	#control
	andi	$t1,$t1,0x0001
	beq	$t1,$0,waitloop
	lw	$v0,4($t0)	#data
	
wait:
	lw	$t1,8($t0)	#control
	andi	$t1,$t1,0x0001
	beq	$t1,$0,wait
	lw $t9,  BACKSPACE_KEY
	beq $v0, $t9, backspace
	sw	$v0,12($t0)	#data
	j waitloop
	
backspace:
  # Se o caractere for "backspace", apaga o último caractere do display
  # Para fazer isso, escrevemos um caractere vazio no endereço de saída MMIO
  li $t3, ' '        # Armazena o caractere de espaço vazio em $t3
  sb $t3,12($t0)     # Escreve o caractere vazio no endereço de saída MMIO
  sb $t0,12($t0)     # Escreve novamente o caractere lido (o que estava antes do backspace) no endereço de saída MMIO
  j waitloop        # Continua lendo caracteres

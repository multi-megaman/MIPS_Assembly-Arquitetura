.data
MMIO_INPUT:  .word   0xffff000c  # Endereço de entrada MMIO
MMIO_OUTPUT: .word 0xffff0004  # Endereço de saida MMIO
BACKSPACE_KEY: .word 0x00000008         # Valor do caractere "backspace" (ascii 8)
NEW_LINE_KEY: .word 0x0A #Valor do caracter "\n" (ascii)
USER_COMMAND: .space 124 #Serah aqui que os comandos que o usuario digitar serao guardados byte a byte.
tamanho_user_command: .word 124 #Tamanho
teste_line_breaker: .asciiz"\n"
#Macros
.macro print_string_by_address(%string_register)
	addi $sp, $sp, -4
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	
	addi $v0, $0, 4
	addi $a0, %string_register, 0
	syscall
	
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
.end_macro

#Macros
.macro print_string(%string)
	addi $sp, $sp, -4
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	
	addi $v0, $0, 4
	la $a0, %string
	syscall
	
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
.end_macro

.text
	lui	$t0,0xffff	#ffff0000
	la $t2, USER_COMMAND #$t2 vai ser responsavel por escrever byte a byte em USER_COMMAND
	lw $t4, tamanho_user_command 
	add $t4, $t4, $t2 #$t4 representa o endereco limite da string que o usuario pode digitar 
	addi $t4, $t4, -2 #O limite da string vai ser o final -2 ja que o ultimo byte dessa string vamos colocar o "\0" e o penultimo vai ser o "\n"
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
	lw $t8, NEW_LINE_KEY
	beq $v0, $t9, backspace
	beq $v0, $t8, new_line
	#=====Armazenar o novo byte em USER_COMMAND
	sb $v0, 0($t2) #Salvando o byte em $t2
	addi $t2, $t2, 1 #partindo para o proximo byte
	beq $t2, $t4, usuario_chegou_ao_limite_da_string #Se $t2 chegou no final do USER_COMMAND - 2 então
	 
	#Salvando no display
	sw	$v0,12($t0)	#data
	#addi $t2, $0, 0x10000050
	print_string_by_address($t2)
	j waitloop
	
usuario_chegou_ao_limite_da_string:
	sb $t8, 1($t2) #Colocando "\n" no penultimo byte reservado para o USER_COMMAND
	sb $0, 2($t2) #Colocando "\0" no ultimo byte reservado para o USER_COMMAND
	j new_line
	
backspace:
  # Se o caractere for "backspace", apaga o ultimo caractere do display
  # Para fazer isso, escrevemos um caractere vazio no endereço de saída MMIO
  li $t3, ' '        # Armazena o caractere de espaço vazio em $t3
  sb $t3,12($t0)     # Escreve o caractere vazio no endereço de saída MMIO
  sb $t0,12($t0)     # Escreve novamente o caractere lido (o que estava antes do backspace) no endereço de saida MMIO
  j waitloop        # Continua lendo caracteres
  
new_line:
	
	sw $t8,12($t0)	#Salvando o "\n" no display
	print_string(USER_COMMAND)
	print_string(teste_line_breaker)
	
	#TO DO  = Envia a string condita em USER_COMMAND para a funcao do parser
	
	#zerar USER_COMMAND
	la $t2, USER_COMMAND  #$t2 vai ser responsavel por escrever byte a byte em USER_COMMAND
	loop_zerar_user_command:
		sb $0, 0($t2) #zerando byte 
		addi $t2, $t2, 1 #indo para o proximo byte
		beq $t2, $t4,fim_loop_zerar_user_command  #se $t2 chegou no limite do USER_COMMAND, significa que todo USER_COMMAND foi zerado
		j loop_zerar_user_command
		fim_loop_zerar_user_command:
			la $t2, USER_COMMAND  #$t2 vai ser responsavel por escrever byte a byte em USER_COMMAND
	j waitloop        # Continua lendo caracteres
	
print_string_on_mmio_display: #Params ($a0 -> endereco de memoria onde a string estah, essa funcao vai imprimir a string ate achar um \0 | address int)

jr $ra #Return (None)

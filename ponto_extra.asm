.data
MMIO_INPUT:  .word   0xffff000c  # Endereço de entrada MMIO
MMIO_OUTPUT: .word 0xffff0004  # Endereço de saida MMIO
BACKSPACE_KEY: .word 0x00000008         # Valor do caractere "backspace" (ascii 8)
NEW_LINE_KEY: .word 0x0A #Valor do caracter "\n" (ascii)
USER_COMMAND: .space 124 #Serah aqui que os comandos que o usuario digitar serao guardados byte a byte.
tamanho_user_command: .word 124 #Tamanho
teste_line_breaker: .asciiz"\n"
buffer_number_to_string: .space 15
tamanho_buffer_number_to_string: .byte 15
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

.globl print_string_on_MMIO, print_number_on_MMIO
#j fim_mmio
	lui	$s0,0xffff	#ffff0000
	la $s2, USER_COMMAND #$s2 vai ser responsavel por escrever byte a byte em USER_COMMAND
	lw $s4, tamanho_user_command 
	add $s4, $s4, $s2 #$s4 representa o endereco limite da string que o usuario pode digitar 
	addi $s4, $s4, -2 #O limite da string vai ser o final -2 ja que o ultimo byte dessa string vamos colocar o "\0" e o penultimo vai ser o "\n"
waitloop:
	lw	$s1,0($s0)	#control
	andi	$s1,$s1,0x0001
	beq	$s1,$0,waitloop
	lw	$v0,4($s0)	#data
	
wait:
	lw	$s1,8($s0)	#control
	andi	$s1,$s1,0x0001
	beq	$s1,$0,wait
	lw $t9,  BACKSPACE_KEY
	lw $t8, NEW_LINE_KEY
	beq $v0, $t9, backspace
	beq $v0, $t8, new_line
	#=====Armazenar o novo byte em USER_COMMAND
	sb $v0, 0($s2) #Salvando o byte em $s2
	addi $s2, $s2, 1 #partindo para o proximo byte
	beq $s2, $s4, usuario_chegou_ao_limite_da_string #Se $s2 chegou no final do USER_COMMAND - 2 então
	 
	#Salvando no display
	sw	$v0,12($s0)	#data
	#addi $s2, $0, 0x10000050
	print_string_by_address($s2)
	j waitloop
	
usuario_chegou_ao_limite_da_string:
	sb $t8, 1($s2) #Colocando "\n" no penultimo byte reservado para o USER_COMMAND
	sb $0, 2($s2) #Colocando "\0" no ultimo byte reservado para o USER_COMMAND
	j new_line
	
backspace:
  # Se o caractere for "backspace", apaga o ultimo caractere do display
  # Para fazer isso, escrevemos um caractere vazio no endereço de saída MMIO
  li $s3, ' '        # Armazena o caractere de espaço vazio em $s3
  sb $s3,12($s0)     # Escreve o caractere vazio no endereço de saída MMIO
  sb $s0,12($s0)     # Escreve novamente o caractere lido (o que estava antes do backspace) no endereço de saida MMIO
  j waitloop        # Continua lendo caracteres

#!!!!!!!!!!!!!!!!!===========Eh aqui que o comando eh enviado para o parser ===========!!!!!!!!!!!!!!!!!
new_line:
	
	sw $t8,12($s0)	#Salvando o "\n" no display
	print_string(USER_COMMAND)
	print_string(teste_line_breaker)
	la $a0, USER_COMMAND
	#jal print_on_MMIO #Funciona!
	jal parse_string
	#zerar USER_COMMAND
	la $s2, USER_COMMAND  #$s2 vai ser responsavel por escrever byte a byte em USER_COMMAND
	loop_zerar_user_command:
		sb $0, 0($s2) #zerando byte 
		addi $s2, $s2, 1 #indo para o proximo byte
		beq $s2, $s4,fim_loop_zerar_user_command  #se $s2 chegou no limite do USER_COMMAND, significa que todo USER_COMMAND foi zerado
		j loop_zerar_user_command
		fim_loop_zerar_user_command:
			la $s2, USER_COMMAND  #$s2 vai ser responsavel por escrever byte a byte em USER_COMMAND
	j waitloop        # Continua lendo caracteres
	
print_string_on_mmio_display: #Params ($a0 -> endereco de memoria onde a string estah, essa funcao vai imprimir a string ate achar um \0 | address int)

jr $ra #Return (None)

#===== Funcao que imprime no display do MMIO uma determinada string dado seu endereco=====
print_string_on_MMIO: #Params ($a0 -> endereco da memoria da string | address int)
	add $t2, $0, $a0 #Copiando o endereco de memoria para $t2
	lui	$t0,0xffff	#ffff0000
	wait_to_print_string_on_MMIO:
		lw	$t1,8($t0)	#control
		andi	$t1,$t1,0x0001 #verificando se podemos imprimir um caracter na tela 
		beq	$t1,$0,wait_to_print_string_on_MMIO
		lb $t3, 0($t2) #carregando o byte que vai ser impresso
		sw $t3,12($t0)	#data
		addi $t2, $t2, 1 #indo para o proximo byte
		beqz $t3, fim_print_string_on_MMIO #se o caracter lido eh 0, entao chegamos no fim da string a ser impressa
		j wait_to_print_string_on_MMIO
	fim_print_string_on_MMIO:
jr $ra #Return (None)

#===== Funcao que imprime no display do MMIO um numero=====
print_number_on_MMIO: #Params ($a0 -> numero a ser impresso | number)

	#Converter de inteiro para string
	add $t1, $a0, $0 #passando $a0 para $t1
	la $t3, buffer_number_to_string
	lb $t5, tamanho_buffer_number_to_string
	addi $t5, $t5, -1 #subtrair 1 do total, ja que o ultimo byte vai ser o "\0"
	addi $t6, $0, 1 #contador para saber se ja chegamos ao final da string
	addi $t7, $0, 10 #10 eh a base que nos queremos transformar nosso numero
	convert_number_to_string_loop:
    		div $t1, $t7         # Dividir $t1 por 10
    		mflo $t1             # $t1 = quociente
    		mfhi $t4             # $t4 = resto
    		addi $t4, $t4, '0'   # Converter o digito para um caractere ASCII
    		sb $t4, 0($t3)       # Armazenar o caractere na string
    		addi $t3, $t3, 1     # Mover para o proximo caractere na string
    		addi $t6, $t6, 1 	#incrementando o contador
    		beq $t6, $t5, end_convert_number_to_string_loop #se o contador chegar no limite do tamanho, sai do loop
    		bnez $t1, convert_number_to_string_loop   # Repetir ate que o quociente seja zero
	end_convert_number_to_string_loop:
		#Invertendo os numeros do buffer
		la $t2, buffer_number_to_string #Carregando a posicao inicial do buffer em $t2
		strLen:                 #Pegando o tamanho total da string
			lb      $t0, 0($t2)   #Carregando o valor em $t2
			add     $t2, $t2, 1 #Indo para o proximo valor
			bne     $t0, $zero, strLen #Caso nao tenhamos chegado em "\0" ainda, continuamos ate $t2 ter o tamanho da string

			la $t5, buffer_number_to_string #$t5 vai conter a posicao inicial do buffer, para compararmos com $t2 que vai percorrer o buffer de tras para frente
			lui	$t0,0xffff	#ffff0000 (MMIO address)
			Loop_print_byte_a_byte:
			sub     $t2, $t2, 1     #Indo para o proximo byte a ser impresso (para tras)
			#la      $t0, 0($t2)   #carregando o valor 
			lb      $t3, 0($t2) # 
			#syscall #Printando o byte em $a0 (que ja estah com a ordem invertida)
			wait_to_print_byte_on_MMIO:
				lw	$t1,8($t0)	#control
				andi	$t1,$t1,0x0001 #verificando se podemos imprimir um caracter na tela 
				beq	$t1,$0,wait_to_print_byte_on_MMIO
				#$t3 jah foi carregado com o byte que vamos imprimir
				sw $t3,12($t0)	#data
			#bnez $t2, Loop_print_byte_a_byte
			#Aqui o $a0 ainda contem o endereco inicial que queremos
			bge $t2, $t5,  Loop_print_byte_a_byte #se $t2 nao tiver chegado em $t5 (inicio da string) entao continuamos 
			#Aqui o programa acaba
jr $ra #Return (None)
fim_mmio:

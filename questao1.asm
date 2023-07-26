.data
#para fazer o teste basta colocar na linha 26 o numero da função que desejar testar, sendo 1 a primeira função e 5 a ultima
#estado elas ordenadas na ordem que aparecem no documento de cima para baixo

#aqui em baixo temos os parametros de cada função com o nome da mesma no inicio

strcpy_destino: .space 50
strcpy_source: .asciiz "a string que foi copiada foi impressa"

memcpy_num: .word 32
memcpy_destino: .space 50
memcpy_source: .asciiz "E esse foi o teste dois eu acho? isso se tudo foi impresso!!!"

strcmp1: .asciiz "string2"
strcmp2: .asciiz "string1"

strncmp1: .asciiz "teste12"
strncmp2: .asciiz "teste1"
strncmp_num: .word 7

strcat_destino: .asciiz "como pode ver "
strcat_source: .asciiz "a string foi concatenada"

.text
#caso deseje testar todas as funções rapidamente basta trocar o numero abaixo indo de 1 a 5
li $s0, 1#indica qual função sera testada

beq $s0, 1, teste1 #strcpy
beq $s0, 2, teste2 #memcpy
beq $s0, 3, teste3 #strcmp
beq $s0, 4, teste4 #strncmp
beq $s0, 5, teste5 #strcat
j end

teste1:
	la $a0, strcpy_destino
	la $a1, strcpy_source
	jal strcpy
	move $a0, $v0
	li $v0, 4
	syscall
	j end

teste2:
	la $a0, memcpy_destino
	la $a1, memcpy_source
	lw $a2, memcpy_num
	jal memcpy
	move $a0, $v0
	li $v0, 4
	syscall
	j end
	
teste3: 
	la $a0, strcmp1
	la $a1, strcmp2
	jal strcmp
	move $a0, $v0
	li $v0, 1
	syscall
	j end
	
teste4:
	la $a0 strncmp1
	la $a1 strncmp2
	lw $a2 strncmp_num
	jal strncmp
	move $a0, $v0
	li $v0,1
	syscall
	j end
	
teste5:
	la $a0, strcat_destino
	la $a1, strcat_source
	jal strcat
	move $a0, $v0
	li $v0, 4
	syscall
	j end
	
	

strcpy:	#função que copia uma string
	move $t0, $a0 #tirando os endereços das registradores de parametro e colocando em registradores temporarios
	move $t1, $a1
	move $v0, $t0 #salvando o endereço destino para retornar no final da função
	loop:
		lb $t2, ($t1) #carrega 1 bit da memoria em $t2 da string origem
		beqz $t2, exit #compara $t2 com zero para saber se ja chegou ao fim da string
		sb $t2, ($t0) #guarda na memoria destino o bit em $t2
		addi $t0, $t0, 1 #incrementa o endereço de memoria
		addi $t1, $t1, 1
		j loop
	exit:
		sb $zero, 1($t0) #adiciona o zero ao final da string
		jr $ra
	
###################################################################################################################################################
	
memcpy:	
	move $t0, $a0 #tirando os dados dos registradores de parametros e colocando em registradores temporarios
	move $t1, $a1
	move $t2, $a2
	move $v0, $a0
	li $t3, 0 #contador que sera usado para saber quando parar
	loop1:
		beq $t3, $t2, exit1 #ve se o contador chegou ao numero especificado
		lb $t4, ($t1) #carrega o bit em $t4
		sb $t4, ($t0) #salva o bit na memoria
		addi $t0, $t0, 1 #icrementa os endereços de memoria e o contador
		addi $t1, $t1, 1
		addi $t3, $t3, 1
		j loop1
	
	exit1:
		jr $ra
		
###################################################################################################################################################

strcmp:
	move $t0, $a0 #tirando os dados dos registradores de parametros e colocando em registradores temporarios
	move $t1, $a1
	loop2:
		lb $t2, ($t0) #carregando os bits
		lb $t3, ($t1)
		beqz $t2, exit2 #verificando se chegou ao final da string em ambas as strings
		beqz $t3, exit2
		bne $t2, $t3, exit2 #verifica se eles são diferentes
		addi $t0, $t0, 1 #incrementa os endereços de memoria
		addi $t1, $t1, 1
		j loop2
		
	exit2:
	blt $t2, $t3, primeiromenor #verifica qual dos 3 casos aconteceu
	beq $t2, $t3, iguais
	bgt $t2, $t3, primeiromaior
	
	
	primeiromenor:
	li $v0, -1
	jr $ra
	
	iguais:
	li $v0, 0
	jr $ra
	
	primeiromaior:
	li $v0, 1
	jr $ra

########################################################################################

strncmp:
	move $t0, $a0 #tirando os dados dos registradores de parametros e colocando em registradores temporarios
	move $t1, $a1
	move $t6, $a2 
	li $t7, 1 #criando o contador
	loop3:
		lb $t2, ($t0) #carregando os bits
		lb $t3, ($t1)
		beq $t6, $t7, exit3
		beqz $t2, exit3 #verificando se chegou ao final da string em ambas as strings
		beqz $t3, exit3
		bne $t2, $t3, exit3 #verifica se eles são diferentes
		addi $t0, $t0, 1 #incrementa os endereços de memoria
		addi $t1, $t1, 1
		addi $t7, $t7, 1 #incrementa o contador
		j loop3
		
	exit3:
	blt $t2, $t3, primeiromenor1 #verifica qual dos 3 casos aconteceu
	beq $t2, $t3, iguais1
	bgt $t2, $t3, primeiromaior1
	
	
	primeiromenor1:
	li $v0, -1
	jr $ra
	
	iguais1:
	li $v0, 0
	jr $ra
	
	primeiromaior1:
	li $v0, 1
	jr $ra	
	
#################################################################################################

strcat:
	move $t0, $a0 #tirando os dados dos registradores de parametros e colocando em registradores temporarios
	move $t1, $a1
	move $v0, $a0
	loop4:
		lb $t2, ($t0) #carregando um bit em $t2
		beqz $t2, loop5 #verificando se a primeira string chegou ao final
		addi $t0, $t0, 1 #incrementando o endereço base da string
		j loop4
	
	loop5:
		lb $t2, ($t1) #carrega um bit em t2
		beqz $t2, exit4 #verifica se a string chegou ao final
		sb $t2, ($t0) #salva o bit de $t2 concatenando com a primeira string
		addi $t0, $t0, 1 #incrementa o endereço base das strings
		addi $t1, $t1, 1
		j loop5
		
	exit4:
	li $t5, 0
	sb $t5, ($t0) #adiciona o 0 ao final da string
	jr $ra
	
end:
	li $v0, 10
	syscall

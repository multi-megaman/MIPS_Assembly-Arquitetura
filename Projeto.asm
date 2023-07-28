.data
#===== Bits reservados para cada item do card�pio =====
	#codigo do card�pio -> 1-20          = 5   bits(2^5 = 32 valores)        arredondando para words = 16bits    unsigned
	#preco (centavos)    -> 0-99999  =  14 bits(2^14 = 16384 valores) arredondando para bytes = 16bits  unsigned
	#descricao (letras) -> 0-60         =  60*8 = 480 bits 			   arredondando para bytes = 480bits unsigned
#Bits totais para um item do card�pio = 16 + 16 + 480 = 512 bits -> 64 bytes

#Espacos totais para os 20 itens do card�pio 64x20 = 1.280
cardapio: .space 1280					    #bytes -> quantidade em bytes reservados para todos os possiveis 20 itens do card�pio
#Valores extras para o funcionamento do cardapio
tamanho_total_cardapio: .word 1280		  # int -> tamanho total do card�pio em bytes
limite_cardapio: .half 20   		                   #int -> indica qual o limite de itens do card�pio
ponteiro_cardapio: .half 0 		                   #int -> Sempre vai estar apontando para a proxima posi��o livre do cardapio. Quando chega em limite_cardapio, indica que a proxima posi��o livre est� fora do espa�o reservado.
tamanho_codigo_item_cardapio: .byte 2          #int -> indica o tamanho em bytes reservados para o c�digo do card�pio
tamanho_preco_item_cardapio: .byte 2 	  #int -> indica o tamanho em bytes reservados para o c�digo do card�pio
tamanho_descricao_item_cardapio: .byte 60 #int -> indica o tamanho em bytes reservados para a descri��o do item do card�pio 
tamanho_total_item_cardapio: .byte 64        #int -> indica o tamanho em bytes reservados para um item do card�pio

#textos reservados
falha_criacao_item_cardapio_codigo_cadastrado: .asciiz "Falha: numero de item ja cadastrado\n"
falha_criacao_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"
falha_criacao_item_cardapio_cheio: .asciiz "Falha: cardapio cheio\n"

falha_remover_item_cardapio_codigo_nao_cadastrado: .asciiz "Falha: codigo informado nao possui item cadastrado no cardapio\n"
falha_remover_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"

#Macros
.macro print_string(%string)
	addi $v0, $0, 4
	la $a0, %string
	syscall
.end_macro

#testes
string_usuario: .space 60
input_string_usuario: .asciiz"Digite um coment�rio para o item por favor: "
char: .ascii "a"

.text
main:
#!!!!!!!!!!!!!! INICIO DA ZONA DE TESTES !!!!!!!!!!!!!!!!!!!!!!!!!
#---�rea de testes para pegar a descri��o do usu�rio, essa parte ser� substituida com o CLI posterior, mas por agora para se adicionar um item no card�pio, � preciso ler essa string
addi $v0, $0, 4 #Printar String
la $a0, input_string_usuario
syscall

la $a0, string_usuario #carrega o endere�o de string em $a0 para ser utilizado na leitura (saber onde vai come�ar a armazenar os caracteres?)
addi $a1, $0, 60 #carregando o maximo de caracteres para leitura
addi $v0,$0, 8 # Servi�o 8 l� uma string
syscall
add $a2, $0, $a0 #armazena o valor lido em $a2 (string do usuario) 
#OBS: A descri��o dos itens por enquanto � a mesma para todos eles, j� que estamos pegando apenas uma �nica string para isso

#---Valores de teste referentes ao id do item ($a0) e ao pre�o dele ($a1)
addi $a0, $0, 1
addi $a1, $0, 1000
jal cardapio_ad
jal cardapio_ad #Erro: Item j� cadastrado
jal cardapio_ad #Erro: Item j� cadastrado

addi $a0, $0, 2
addi $a1, $0, 2000
jal cardapio_ad

addi $a0, $0, 3
addi $a1, $0, 3000
jal cardapio_ad

addi $a0, $0, 4
addi $a1, $0, 70
jal cardapio_ad

addi $a0, $0, 5
addi $a1, $0, 6467
jal cardapio_ad

addi $a0, $0, 10
addi $a1, $0, 99999
jal cardapio_ad

addi $a0, $0, 9
addi $a1, $0, 99999
jal cardapio_ad

addi $a0, $0, 7
addi $a1, $0, 999
jal cardapio_ad

addi $a0, $0, 8
addi $a1, $0, 99999
jal cardapio_ad

addi $a0, $0, 6
addi $a1, $0, 6893
jal cardapio_ad

addi $a0, $0, 11
addi $a1, $0, 67812
jal cardapio_ad

addi $a0, $0, 15
addi $a1, $0, 28
jal cardapio_ad

addi $a0, $0, 12
addi $a1, $0, 1500
jal cardapio_ad

addi $a0, $0, 13
addi $a1, $0, 67278
jal cardapio_ad

addi $a0, $0, 14
addi $a1, $0, 67176
jal cardapio_ad

addi $a0, $0, 16
addi $a1, $0, 16512
jal cardapio_ad

addi $a0, $0, 17
addi $a1, $0, 89321
jal cardapio_ad

addi $a0, $0, 18
addi $a1, $0, 87234
jal cardapio_ad

addi $a0, $0, 19
addi $a1, $0, 17821
jal cardapio_ad

#comentar  para testar o cardapio_rm 20
addi $a0, $0, 20
addi $a1, $0, 78214
jal cardapio_ad

addi $a0, $0, 26
addi $a1, $0, 78214
jal cardapio_ad # Erro: C�digo inv�lido

addi $a0, $0, 0
addi $a1, $0, 78214
jal cardapio_ad # Erro: C�digo inv�lido

#Remover item
addi $a0, $0, 21
jal cardapio_rm #Erro: c�digo inv�lido

#addi $a0, $0, 20
#jal cardapio_rm #Erro: c�digo n�o cadastrado

addi $a0, $0, 20 #testando a remo��o do ultimo item
jal cardapio_rm #Sucesso

addi $a0, $0, 19 #testando a remo��o do ultimo item (mas n�o no limite)
jal cardapio_rm #Sucesso

addi $a0, $0, 4 #testando a remo��o de um item aleatorio
jal cardapio_rm #Sucesso

addi $a0, $0, 1 #testando a remo��o do primeiro item
jal cardapio_rm #Sucesso

#Adicionando um item ap�s uma dele��o
addi $a0, $0, 19 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 12394
jal cardapio_ad #Sucesso

addi $a0, $0, 20 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 11111
jal cardapio_ad #Sucesso

addi $a0, $0, 4 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 74848
jal cardapio_ad #Sucesso

addi $a0, $0, 4 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 73748
jal cardapio_ad #Erro: Item j� cadastrado

addi $a0, $0, 1 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 68356
jal cardapio_ad #Sucesso

#Checando a existencia de um c�digo no card�pio
addi $a0, $0, 3
addi $a1, $0, 1600
jal checar_existencia_de_codigo #Retorna 1 (c�digo encontrado)

#Encerrar programa
addi $v0, $0, 10
syscall

#=====Criar item no card�pio=====
cardapio_ad: #Params ($a0 -> codigo do item  | int          2 bytes,
				     #$a1 ->  preco do item   | int        2 bytes,
				     #$a2 -> descricao	    | string 60 bytes)
	#Registradores temporarios utilizados:
	#$t0 -> limite_cardapio
	#$t1 -> endere�o do ponteiro_cardapio
	#$t2 -> valor do ponteiro_cardapio
	#$t3 -> endere�o inicial do proximo espa�o livre de item de card�pio
	#$t4 -> total de bytes do item do cardapio
	#$t5 -> Um faz tudo
	
	#==Checando para ver se o codigo do cardapio ja nao foi inserido
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_existencia_de_codigo #recebendo $a0 como entrada (c�digo do item a ser adicionado) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	bnez $v0, falha_cardapio_codigo_existe #if (checar_existencia_de_codigo != 0) {return erro} 
	
	#=============================================
	lhu $t0, limite_cardapio
	la $t1, ponteiro_cardapio
	lhu $t2, ponteiro_cardapio
	lbu $t4, tamanho_total_item_cardapio
	
	#== Checando para ver se o c�digo digitado est� entre 1-20
	bge $a0, 1, checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_codigo_alcance  # Pula para o final da fun��o

	checar_limite_superior:
	ble $a0, $t0, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele est� dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da fun��o
	
	dentro_do_limite:
	#==Checando para ver se o card�pio j� n�o est� cheio		
	beq $t0, $t2, falha_cardapio_cheio

	#==Adicionando o item no cardapio
	la $t3, cardapio 	#Carregando o endere�o inicial do cardapio
	multu $t2,$t4 	#Calculando o offset para se chegar no proximo espa�o de mem�ria livre reservado para um item (67 bytes). ponteiro_cardapio * tamanho_total_item_cardapio 
	mflo $t5 			#$t5 recebe o resultado da multiplica��o anterior
	add $t3, $t3, $t5  #adiciona o offset necess�rio calculado anteriormente com o valor base do card�pio, assim iremos diretamente para o proximo espa�o vazio da lista.
	sh $a0, 0($t3)     	#Salva o byte referente ao c�digo do item do cardapio na primeira posi��o 
	
	lb $t5, tamanho_codigo_item_cardapio #Carrega o valor reservado de bytes para o c�digo do card�pio em $t5
	add $t3, $t3, $t5  #soma o valor atual do offset com o valor reservado de bytes para o c�digo do card�pio, fazendo com que $t3 fique apontando para o espa�o vazio reservado ao pre�o do item
	sh $a1, 0($t3)		#Salva o half referente ao pre�o do item do card�pio na posi��o depois do c�digo do pedido
	
	lb $t5, tamanho_preco_item_cardapio #Carrega o valor reservado de bytes para o pre�o do card�pio em $t5
	add $t3, $t3, $t5  #soma o valor atual do offset com o valor reservado de bytes para o pre�o do card�pio, fazendo com que $t3 fique apontando para o espa�o vazio reservado a descri��o do item
	
	addi $t2, $t2, 1	#Acrescenta 1 ao ponteiro_cardapio
	sh $t2, 0($t1) 	#armazena o valor ponteiro_cardapio + 1 no endere�o do ponteiro_cardapio
	
	add $a3, $0, $t3   #Carregando o endere�o destino da c�pia de string para $a3
	#a2 j� possui o valor da string que queremos copiar para $a3

	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da c�pia
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	j sucesso
	
	falha_cardapio_cheio:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_criacao_item_cardapio_cheio)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_ad
	falha_cardapio_codigo_existe:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_criacao_item_cardapio_codigo_cadastrado)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		addi $v0, $0, 1
		j fim_cardapio_ad
	falha_cardapio_codigo_alcance:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_criacao_item_cardapio_codigo_invalido)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		addi $v0, $0, 1
		j fim_cardapio_ad
	sucesso:
		addi $v0, $0, 0
	fim_cardapio_ad:
jr $ra		#Return ($v0 -> sucesso(0)/fracasso(1) | bool)


#===== Deletar item do card�pio =====
cardapio_rm:  #Params ($a0 -> codigo do item  | int  2 byts)

	#== Checando para ver se o c�digo digitado est� entre 1-20
	bge $a0, 1, rm_checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_rm_codigo_alcance  # Pula para o final da fun��o
	rm_checar_limite_superior:
	ble $a0, $t0, rm_dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele est� dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da fun��o
	rm_dentro_do_limite:
	
	#== Checando para ver se o c�digo existe dentro do card�pio
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_existencia_de_codigo #verificar se o c�digo inserido realmente existe no card�pio
	lw $ra, 0($sp)	#Recupenrando o $ra  antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	beqz $v0, falha_cardapio_rm_codigo_inexistente #Se o retorno de checar_existencia_de_codigo for 0, significa que o c�digo inserido n�o existe
	
	#== Caso o c�digo seja v�lido e exista, vamos "Deletar a entrada" movendo todos os bytes a direita desse item do card�pio para a esquerda. Caso seja o ultimo item, apenas zeramos sua entrada
	addi $sp, $sp, -16
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	sw $a0, 4($sp)#Salvando o valor de $a0
	sw $a1, 8 ($sp)#Salvando o valor de $a1
	sw $a2, 12($sp)#Salvando o valor de $a2
	la $t4, cardapio
	lbu $t0, tamanho_total_item_cardapio #Carregando o tamanho total de um item no cardapio
	multu $v1, $t0 # Calculando o offset necess�rio para ir diretamente para a primeira posi��o do item que ser� "deletado"
	mflo $t1          #offset para se chegar no item que vai ser "deletado"
	add $a2, $t4, $t1 #a2 est� apontando exatamente para o local inicial onde o conjunto vai ser copiado (apontando para o item que vai ser "deletado")
	add $a0, $a2, $t0 # $a0 ser� o proximo item referente ao item que vai ser "deletado"
	lw $t2, tamanho_total_cardapio 
	add $a1, $t2, $t4 #Calculando o endere�o final do card�pio
	jal shift_mem_left #Params ($a0 -> local inicial do conjunto de bytes que vai ser copiado | memory address,
					 # $a1 -> local final do conjunto de bytes que vai ser copiado   | memory address,
					 # $a2 -> local inicial para onde o conjunto vai ser copiado       | memory address)
	lw $a2, 12($sp)#Carregando de volta $a2 
	lw $a1, 8($sp)#Carregando de volta $a1
	lw $a0, 4($sp)#Carregando de volta $a0
	lw $ra, 0($sp)#Carregando de volta $ra 
	addi $sp, $sp, 16 
	
	#atualizando o ponteiro
	lhu $t2,  ponteiro_cardapio
	la $t1, ponteiro_cardapio
	subiu $t2, $t2, 1	#Subtrai 1 ao ponteiro_cardapio
	sh $t2, 0($t1) 	#armazena o valor ponteiro_cardapio - 1 no endere�o do ponteiro_cardapio
	
	addi $v0, $0, 0 	#sucesso
	
j fim_cardapio_rm
falha_cardapio_rm_codigo_inexistente:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_remover_item_cardapio_codigo_nao_cadastrado)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_rm
falha_cardapio_rm_codigo_alcance:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_remover_item_cardapio_codigo_invalido)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original

		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_rm
fim_cardapio_rm: 
jr $ra	       #Return ($v0 -> sucesso (0)/fracasso(1) | bool)


#===== Chegar se um id especifico j� est� no cardapio ===== 
checar_existencia_de_codigo: #Params($a0 -> codigo do item | int)
	#Registradores temporarios utilizados:
	#$t3 -> C�digo do atual item sendo lido
	#$t4 -> contador de itens de cardapio ja percorridos
	#$t5 -> ponteiro_cardapio
	#$t6 -> registrador que vai percorrer de c�digo em c�digo
	#$t7 -> tamanho total de um item no card�pio (utilizado para fazer os devidos offsets)
	addi $t4, $0, 0
	lb $t5, ponteiro_cardapio
	la $t6, cardapio 
	lb $t7, tamanho_total_item_cardapio
	
	beq $t5, $0, nao_existe #if (ponteiro_cardapio == 0) {return 0}
	loop_checagem:
		beq $t4, $t5, nao_existe #if (contador_itens == qnt_itens) {return 0}  Isso significa que, se tivermos percorrido todos os itens e n�o achamos um c�digo igual, retornamos zero
		lh $t3, ($t6) #Como $t6 sempre vai estar apontando para o primeiro byte do item do card�pio, $t6 sempre vai estar apontando para o c�digo daquele item
		beq $a0, $t3, existe	#if (codigo_atual == codigo_parametro) {return 1}
		addi $t4, $t4, 1	#adiciona mais um ao contador de itens do cardapio
		add, $t6, $t6, $t7 #adicionando o offset a $t6 para que ele v� para o proximo c�digo do proximo item
		j loop_checagem
	nao_existe:
		addi $v0, $0, 0
		addi $v1, $0, -1
		j fim_checar_existencia_de_codigo 
	existe:
		addi $v0, $0, 1
		add $v1, $0, $t4 #salvando o valor do contador em $v1, assim $v1 vai retornar a posi��o onde esse item foi encontrado
	fim_checar_existencia_de_codigo:
jr $ra # Return($v0 -> 1 se o c�digo j� existe e 0 caso ele n�o exista | bool
			#$v1 -> Posi��o no card�pio onde esse item foi encontrado | int)


#===== Deslocar uma quantidade x ($a1 - $a0) de bits para a esquerda ($a2)
shift_mem_left: #Params ($a0 -> local inicial do conjunto de bytes que vai ser copiado | memory address,
					 # $a1 -> local final do conjunto de bytes que vai ser copiado   | memory address,
					 # $a2 -> local inicial para onde o conjunto vai ser copiado       | memory address)
#Registradores temporarios utilizados:
#$t0 -> vai percorrer o conjunto de bits e vai copia-los
#$t1 -> vai percorrer, junto com o $t0 e vai servir para $t0 copiar o byte para $t1
#$t2 -> byte que estar� na posi��o $t0
add  $t0, $0, $a0 # come�a no valor inicial de copia
add $t1, $0, $a2 # come�a nop valor inicial do destino
lb $t2, 0($t0)
#no nosso caso, se $a0 (restante do cardapio) for igual a $a1 (final do cardapio) significa que estamo removendo o ultimo elemento, e, se isso for verdade, faremos uma abordagem diferente
beq $a0, $a1, shift_mem_left_caso_ultimo_elemento

loop_shift_mem_left:
	beq $t0, $a1, fim_shift_mem_left
	sb $t2, 0($t1) #copiando o byte para o destino a esquerda
	sb $0, 0($t0) #apagando o conteudo anterior, j� que ele j� foi copiado
	addi $t0, $t0, 1 #indo para o pr�ximo endere�o de mem�ria
	addi $t1, $t1, 1 #indo para o pr�ximo endere�o de mem�ria
	lb $t2, 0($t0) #carregando o proximo byte
	j loop_shift_mem_left
	
shift_mem_left_caso_ultimo_elemento:
	loop_shift_mem_left_ultimo_elemento:
		beq $t1,  $a1, fim_shift_mem_left #caso tenhamos chegado no final ($a1) encerramos
		#enquanto n�o encerramos, percorremos byte a byte, transformando todos os bytes em 0
		sb $0, 0($t1) #zeramos o byte
		addi $t1, $t1, 1 #passamos para o proximo
	j loop_shift_mem_left_ultimo_elemento
fim_shift_mem_left:
jr $ra		   #Return (None)

#===== Copiar String ===== 
strcpy:	#fun��o que copia uma string
	move $t0, $a3 #tirando os endere�os das registradores de parametro e colocando em registradores temporarios
	move $t1, $a2
	move $v0, $t0 #salvando o endere�o destino para retornar no final da fun��o
	loop:
		lb $t2, ($t1) #carrega 1 bit da memoria em $t2 da string origem
		beqz $t2, exit_strcpy #compara $t2 com zero para saber se ja chegou ao fim da string
		sb $t2, ($t0) #guarda na memoria destino o bit em $t2
		addi $t0, $t0, 1 #incrementa o endere�o de memoria
		addi $t1, $t1, 1
		j loop
	exit_strcpy:
		#sb $zero, 1($t0) #adiciona o zero ao final da string
		jr $ra

#=====Acessar um item do card�pio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra
	
	

.data
#===== Bits reservados para cada item do card�pio =====
	#codigo do card�pio -> 1-20          = 5   bits(2^5 = 32 valores)        arredondando para words = 16bits    unsigned
	#preco (centavos)    -> 0-99999  =  14 bits(2^14 = 16384 valores) arredondando para bytes = 16bits  unsigned
	#descricao (letras) -> 0-60         =  60*8 = 480 bits 			   arredondando para bytes = 480bits unsigned
#Bits totais para um item do card�pio = 16 + 16 + 480 = 512 bits -> 64 bytes

#Espacos totais para os 20 itens do card�pio 64x20 = 1.280
cardapio: .space 1280					    #bytes -> quantidade em bytes reservados para todos os possiveis 20 itens do card�pio
#Valores extras para o funcionamento do cardapio
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

.macro print_string(%string)
	addi $v0, $0, 4
	la $a0, %string
	syscall
.end_macro
#testes
string_usuario: .space 60
char: .ascii "a"

.text
main:
#!!!!!!!!!!!!!! INICIO DA ZONA DE TESTES !!!!!!!!!!!!!!!!!!!!!!!!!
#---�rea de testes para pegar a descri��o do usu�rio, essa parte ser� substituida com o CLI posterior, mas por agora para se adicionar um item no card�pio, � preciso ler essa string
la $a0, string_usuario #carrega o endere�o de string em $a0 para ser utilizado na leitura (saber onde vai come�ar a armazenar os caracteres?)
addi $a1, $0, 60 #carregando o maximo de caracteres para leitura
addi $v0,$0, 8 # Servi�o 8 l� uma string
syscall
add $a2, $0, $a0 #armazena o valor lido em $a2 (string do usuario) 
#OBS: A descri��o dos itens por enquanto � a mesma para todos eles, j� que estamos pegando apenas uma �nica string para isso

#---Valores de teste referentes ao id do item ($a0) e ao pre�o dele ($a1)
addi $a0, $0, 1
addi $a1, $0, 1000
jal cardapio_add
jal cardapio_add #Erro: Item j� cadastrado
jal cardapio_add #Erro: Item j� cadastrado

addi $a0, $0, 2
addi $a1, $0, 2000
jal cardapio_add

addi $a0, $0, 3
addi $a1, $0, 3000
jal cardapio_add

addi $a0, $0, 4
addi $a1, $0, 70
jal cardapio_add

addi $a0, $0, 5
addi $a1, $0, 6467
jal cardapio_add

addi $a0, $0, 10
addi $a1, $0, 99999
jal cardapio_add

addi $a0, $0, 9
addi $a1, $0, 99999
jal cardapio_add

addi $a0, $0, 7
addi $a1, $0, 999
jal cardapio_add

addi $a0, $0, 8
addi $a1, $0, 99999
jal cardapio_add

addi $a0, $0, 6
addi $a1, $0, 6893
jal cardapio_add

addi $a0, $0, 11
addi $a1, $0, 67812
jal cardapio_add

addi $a0, $0, 15
addi $a1, $0, 28
jal cardapio_add

addi $a0, $0, 12
addi $a1, $0, 1500
jal cardapio_add

addi $a0, $0, 13
addi $a1, $0, 67278
jal cardapio_add

addi $a0, $0, 14
addi $a1, $0, 67176
jal cardapio_add

addi $a0, $0, 16
addi $a1, $0, 16512
jal cardapio_add

addi $a0, $0, 17
addi $a1, $0, 89321
jal cardapio_add

addi $a0, $0, 18
addi $a1, $0, 87234
jal cardapio_add

addi $a0, $0, 19
addi $a1, $0, 17821
jal cardapio_add

addi $a0, $0, 20
addi $a1, $0, 78214
jal cardapio_add

addi $a0, $0, 26
addi $a1, $0, 78214
jal cardapio_add # Erro: C�digo fora do alcance

addi $a0, $0, 0
addi $a1, $0, 78214
jal cardapio_add # Erro: C�digo fora do alcance


#Checando a existencia de um c�digo no card�pio
addi $a0, $0, 3
jal checar_existencia_de_codigo #Retorna 1 (c�digo encontrado)

#Encerrar programa
addi $v0, $0, 10
syscall

#=====Criar item no card�pio=====
cardapio_add: #Params ($a0 -> codigo do item  | int        1 byte,
				     #$a1 ->  preco do item   | int        2 bytes,
				     #$a2 -> descricao	    | string 64 bytes)
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
		j fim_cardapio_add
	falha_cardapio_codigo_existe:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_criacao_item_cardapio_codigo_cadastrado)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		addi $v0, $0, 1
		j fim_cardapio_add
	falha_cardapio_codigo_alcance:
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		print_string(falha_criacao_item_cardapio_codigo_invalido)
		lw $a0, 0($sp)	#Recupenrando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		addi $v0, $0, 1
		j fim_cardapio_add
	sucesso:
		addi $v0, $0, 0
	fim_cardapio_add:
jr $ra		#Return ($v0 -> sucesso(0)/fracasso(1) | bool


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
	
	

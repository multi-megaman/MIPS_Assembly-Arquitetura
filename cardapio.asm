.data
#===== Bits reservados para cada item do card�pio =====
	#codigo do card�pio -> 1-20          = 5   bits(2^5 = 32 valores)        arredondando para words = 16bits    unsigned
	#preco (centavos)    -> 0-99999  =  14 bits(2^14 = 16384 valores) arredondando para bytes = 16bits  unsigned
	#descricao (letras) -> 0-60         =  60*8 = 480 bits 			   arredondando para bytes = 480bits unsigned
#Bits totais para um item do card�pio = 16 + 16 + 480 = 512 bits -> 64 bytes

#Espacos totais para os 20 itens do card�pio 64x20 = 1.280
cardapio: .space 1280					    #bytes -> quantidade em bytes reservados para todos os possiveis 20 itens do card�pio
#Valores extras para o funcionamento do cardapio
tamanho_total_cardapio: .word 1280		  # int -> tamanho total do card�pio em bytes | atualmente o fim do cardapio fica no address 1376 (s� para refer�ncia)
limite_cardapio: .half 20   		                   #int -> indica qual o limite de itens do card�pio
ponteiro_cardapio: .half 0 		                   #int -> Sempre vai estar apontando para a proxima posi��o livre do cardapio. Quando chega em limite_cardapio, indica que a proxima posi��o livre est� fora do espa�o reservado.
tamanho_codigo_item_cardapio: .byte 2          #int -> indica o tamanho em bytes reservados para o c�digo do card�pio
tamanho_preco_item_cardapio: .byte 2 	  #int -> indica o tamanho em bytes reservados para o c�digo do card�pio
tamanho_descricao_item_cardapio: .byte 60 #int -> indica o tamanho em bytes reservados para a descri��o do item do card�pio (NAO UTILIZADO :D)
tamanho_total_item_cardapio: .byte 64        #int -> indica o tamanho em bytes reservados para um item do card�pio

#textos reservados
sucesso_criacao_item_cardapio: .asciiz "Item adicionado com sucesso\n"
falha_criacao_item_cardapio_codigo_cadastrado: .asciiz "Falha: numero de item ja cadastrado\n"
falha_criacao_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"
falha_criacao_item_cardapio_cheio: .asciiz "Falha: cardapio cheio\n"

sucesso_remover_item_cardapio: .asciiz"Item removido com sucesso      \n"
falha_remover_item_cardapio_codigo_nao_cadastrado: .asciiz "Falha: codigo informado nao possui item cadastrado no cardapio\n"
falha_remover_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"

aviso_listar_cardapio: .asciiz "Aviso: o cardapio nao possui nenhum item cadastrado ainda\n"

line_breaker: .asciiz"\n"
string_codigo_do_item: .asciiz"Codigo do item: "
string_valor_do_item: .asciiz"Valor do item: "
string_descricao_do_item: .asciiz"Descricao do item: "



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

.macro print_int(%int)
	addi $sp, $sp, -4
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	
	addi $v0, $0, 1
	add $a0, $0, %int
	syscall
	
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
.end_macro

.macro macro_print_number_on_MMIO(%number)
	addi $sp, $sp, -8
	sw $a0, 0($sp) #Salvando o valor de $a0
	sw $ra, 4($sp) #Salvando o valor de $ra para poder voltar a funcao
	add $a0, %number, $0
	jal print_number_on_MMIO
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $a0 antigo
	addi $sp, $sp, 8 #voltando a pilha pro lugar original
.end_macro

.macro macro_print_string_on_MMIO(%string)
	addi $sp, $sp, -8
	sw $a0, 0($sp) #Salvando o valor de $a0
	sw $ra, 4($sp) #Salvando o valor de $ra para poder voltar a funcao
	la $a0, %string
	jal print_string_on_MMIO
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $a0 antigo
	addi $sp, $sp, 8 #voltando a pilha pro lugar original
.end_macro

.macro macro_print_string_on_MMIO_from_memory(%memory)
	addi $sp, $sp, -8
	sw $a0, 0($sp) #Salvando o valor de $a0
	sw $ra, 4($sp) #Salvando o valor de $ra para poder voltar a funcao
	add $a0, %memory, $0
	jal print_string_on_MMIO
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $a0 antigo
	addi $sp, $sp, 8 #voltando a pilha pro lugar original
.end_macro
.text
.globl cardapio_ad, cardapio_rm, cardapio_list, cardapio_format, checar_existencia_de_codigo, retornar_infos_item_cardapio, strcpy
j end_cardapio
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
	
	#Checando para ver se o codigo do cardapio ja nao foi inserido
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
	
	#Checando para ver se o c�digo digitado est� entre 1-20
	bge $a0, 1, checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_codigo_alcance  # Pula para o final da fun��o

	checar_limite_superior:
	ble $a0, $t0, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele est� dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da fun��o
	
	dentro_do_limite:
	#Checando para ver se o card�pio j� n�o est� cheio		
	beq $t0, $t2, falha_cardapio_cheio

	#Adicionando o item no cardapio
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
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da c�pia
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	j sucesso
	
	falha_cardapio_cheio:
		print_string(falha_criacao_item_cardapio_cheio)
		macro_print_string_on_MMIO(falha_criacao_item_cardapio_cheio)
	
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_ad
		
	falha_cardapio_codigo_existe:
		print_string(falha_criacao_item_cardapio_codigo_cadastrado)
		macro_print_string_on_MMIO(falha_criacao_item_cardapio_codigo_cadastrado)
		addi $v0, $0, 1
		j fim_cardapio_ad
		
	falha_cardapio_codigo_alcance:
		print_string(falha_criacao_item_cardapio_codigo_invalido)
		macro_print_string_on_MMIO(falha_criacao_item_cardapio_codigo_invalido)
		addi $v0, $0, 1
		j fim_cardapio_ad
	sucesso:
		addi $v0, $0, 0
		print_string(sucesso_criacao_item_cardapio)
		macro_print_string_on_MMIO(sucesso_criacao_item_cardapio)
	fim_cardapio_ad:
jr $ra		#Return ($v0 -> sucesso(0)/fracasso(1) | bool)


#===== Deletar item do card�pio =====
cardapio_rm:  #Params ($a0 -> codigo do item  | int  2 byts)

	#Checando para ver se o c�digo digitado est� entre 1-20
	bge $a0, 1, rm_checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_rm_codigo_alcance  # Pula para o final da fun��o
	rm_checar_limite_superior:
	ble $a0, $t0, rm_dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele est� dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da fun��o
	rm_dentro_do_limite:
	
	#Checando para ver se o c�digo existe dentro do card�pio
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_existencia_de_codigo #verificar se o c�digo inserido realmente existe no card�pio
	lw $ra, 0($sp)	#Recupenrando o $ra  antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	beqz $v0, falha_cardapio_rm_codigo_inexistente #Se o retorno de checar_existencia_de_codigo for 0, significa que o c�digo inserido n�o existe
	
	#Caso o c�digo seja v�lido e exista, vamos "Deletar a entrada" movendo todos os bytes a direita desse item do card�pio para a esquerda. Caso seja o ultimo item, apenas zeramos sua entrada
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
	print_string(sucesso_remover_item_cardapio)
	macro_print_string_on_MMIO(sucesso_remover_item_cardapio)
	
	j fim_cardapio_rm
	falha_cardapio_rm_codigo_inexistente:
		print_string(falha_remover_item_cardapio_codigo_nao_cadastrado)
		macro_print_string_on_MMIO(falha_remover_item_cardapio_codigo_nao_cadastrado)
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_rm
	falha_cardapio_rm_codigo_alcance:
		print_string(falha_remover_item_cardapio_codigo_invalido)
		macro_print_string_on_MMIO(falha_remover_item_cardapio_codigo_invalido)
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_rm
fim_cardapio_rm: 
jr $ra	       #Return ($v0 -> sucesso (0)/fracasso(1) | bool)


#===== Listar todos os itens do card�pio em ordem crescente por c�digo =====
cardapio_list: #Params (None)
	#Registradores tempor�rios utilizados:
	#$t0 -> ponteiro_cardapio
	#$t1 -> limite_cardapio
	#$t2 -> vai de 1 em 1 at� o limite do card�pio (quantidade de c�digos), assim assegurando que a ordem com que os itens ser�o mostrados ser� a ordem crescente.
	#$t3 -> faz tudo 1
	#$t4 -> faz tudo 2
	addi $sp, $sp, -16
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	sw $ra, 4($sp) #Salvando o valor de $ra j� que chamaremos mais uma fun��o dentro dessa mesma fun��o
	sw $a1, 8($sp) #Salvando o valor de $a1
	sw $a2,12($sp) #Salvando o valor de $a2
	lhu $t0, ponteiro_cardapio
	lhu $t1, limite_cardapio
	addi $t2, $0, 1
	beq $t0, $0, aviso_cardapio_list #Se a lista estiver vazia, retornar apenas o aviso
	
	#print_string(line_breaker)
	#macro_print_string_on_MMIO(line_breaker)
	loop_cardapio_list:
		bgtu $t2, $t1, fim_cardapio_list  #se $t2 ultrapassar o limite do cardapio, indica que j� esgotamos todos os possiveis prints de itens
		addi $sp, $sp, -8 #armazenando mais espaco para guardar o $t2
		sw $t2, 0($sp) #Salvando o valor de $t2 
		sw $t1, 4($sp) #Salvando o valor de $t1 
		add $a0, $0, $t2 #copiando o atual valor de $t2 para servir de entrada para a fun��o de checagem
		jal checar_existencia_de_codigo #Params($a0 -> codigo do item | int)
		beq $v0, 0, nao_fazer_print_cardapio_list #se a checagem tiver um retorno negativo (0), ent�o n�o vamos printar do elemento
		#caso contr�rio, vamos printar o elemento
		add $t3, $0, $v1 #armazenando o index do item achado em $t5
		lbu $t4, tamanho_total_item_cardapio #carrega o tamanho de um item em $t4
		multu $t3, $t4
		mflo $t3 #$t3 armazena o offset necess�rio para se chegar ao item
		la $t4, cardapio
		#Printando o c�digo do item
		
		add $t4, $t4, $t3 #E com essa soma chegamos exatamente a posi��o de mem�ria do item do card�pio
		lhu $t3, 0($t4) #Carregando o valor do c�digo do item
		add $a1, $t3, $0 #Salvando $t3 original em $a1
		add $a2, $t4, $0 #Salvando $t4 original em $a2
		 print_string(string_codigo_do_item)
		 macro_print_string_on_MMIO(string_codigo_do_item)
		 print_int($a1)
		 macro_print_number_on_MMIO($a1)
		 print_string(line_breaker)
		 macro_print_string_on_MMIO(line_breaker)
		 add $t3, $a1, $0 #Recuperando $t3 original
		 add $t4, $a2, $0 #Recuperando de $4 original
		 #Printando o pre�o do item
		 lbu $t3, tamanho_codigo_item_cardapio #Carregando o tamanho do c�digo do item
		 add $t4, $t3, $t4 #Somando o local da mem�ria com o tamanho do c�digo, fazendo com que $t4 esteja agora no pre�o do item
		 lhu $t3, 0($t4) #Carregando o valor do pre�o do item
		add $a1, $t3, $0 #Salvando $t3 original em $a1
		add $a2, $t4, $0 #Salvando $t4 original em $a2
		 print_string(string_valor_do_item)
		 macro_print_string_on_MMIO(string_valor_do_item)
		 print_int($a1)
		 macro_print_number_on_MMIO($a1)
		 print_string(line_breaker)
		 macro_print_string_on_MMIO(line_breaker)
		 add $t3, $a1, $0
		 add $t4, $a2, $0
		 #Printando a descri��o do item
		 lbu $t3, tamanho_preco_item_cardapio #Carregando o tamanho do pre�o do item
		 add $t4, $t3, $t4 #Somando o local da mem�ria com o tamanho do pre�o, fazendo com que $t4 esteja agora na descri��o
		 print_string(string_descricao_do_item)
		 macro_print_string_on_MMIO(string_descricao_do_item)
		 #n�o utilizei o macro j� que ele carrega um  endere�o dentro ele, e, $t4 j� possui um endere�o
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		addi $v0, $0, 4
		add $a0, $0, $t4
		macro_print_string_on_MMIO_from_memory($a0)
		syscall
		lw $a0, 0($sp)	#Recuperando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		 print_string(line_breaker)
		 macro_print_string_on_MMIO(line_breaker)
		 
		nao_fazer_print_cardapio_list:	
			lw $t2, 0($sp) #Pegando $t2 de volta para fazer as devidas
			lw $t1, 4($sp) #Pegando $t1 de volta
			addi $sp, $sp, 8 #Voltando a pilha
			addi $t2, $t2, 1 #incrementando o valor de $t2 at� chegar no limite do card�pio ($t1)
			j loop_cardapio_list
	 aviso_cardapio_list:
	 	print_string(aviso_listar_cardapio)
	 	macro_print_string_on_MMIO(aviso_listar_cardapio)
	 	
	fim_cardapio_list:
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $ra original para poder sair dessa fun��o
	lw $a1, 8($sp) #Recuperando o $a1 original
	lw $a2, 12($sp) #Recuperando o $a2 original
	addi $sp, $sp, 16 #voltando a pilha pro lugar original

jr $ra #Return (None)

#===== Remover todos os itens do card�pio =====
cardapio_format: #Params (None)
	la $t0, cardapio
	lw $t1, tamanho_total_cardapio
	add $t1, $t1, $t0 #Posi��o final do cardapio
	add $t2, $0, $t0 #$t2 vai percorrer o card�pido, indo de $t0 (inicio do cardapio) at� $t1 (final do card�pio) zerando ele por completo byte a byte
	loop_cardapio_format:
		beq $t2, $t1, fim_cardapio_format #Se $t2 for igual a $t1, significa que chegamos no final do card�pio, ent�o podemos encerrar a fun��o
		sb $0, 0($t2)
		addi $t2, $t2, 1 #indo para o proximo byte
		j loop_cardapio_format
	fim_cardapio_format:
jr $ra #Return (None)

#==========Fun��es extras================================================================================

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
		lhu $t3, ($t6) #Como $t6 sempre vai estar apontando para o primeiro byte do item do card�pio, $t6 sempre vai estar apontando para o c�digo daquele item
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
			#$v1 -> Posi��o no card�pio onde esse item foi encontrado, caso n�o tenha sido encontrado, o seu valor ser� -1 | int)
			
#=======Retornar o nome de um item do card�pio========
retornar_infos_item_cardapio: #Params ($a0 -> id do item que o usu�rio gostaria de ter o nome e o pre�o)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	jal checar_existencia_de_codigo #Verificando se o item existe, e, se existir 
	lw $ra, 0($sp)	#Recuperando o $a0 antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	la $t4, cardapio
	lbu $t0, tamanho_total_item_cardapio #Carregando o tamanho total de um item no cardapio
	multu $v1, $t0 # Calculando o offset necess�rio para ir diretamente para a primeira posi��o do item que queremos saber a descri��o
	mflo $t1          #offset para se chegar no item desejado
	add $t2, $t4, $t1 #t2 est� apontando exatamente para o local inicial onde o item desejado est� 
	lbu $t3, tamanho_codigo_item_cardapio #Carregando o tamanho do c�digo do item
	add $t1, $t2, $t3 # $t1 est� apontando para o espa�o de mem�ria do pre�o do item
	lhu $v0, 0($t1) #Carregamos $v0 com o valor que est� em $t1 (o pre�o do item)
	lbu $t3, tamanho_preco_item_cardapio #Carregando o tamanho do pre�o do item
	add $v1, $t1, $t3 #Indo para o primeiro byte da descri��o do item
	j fim_retornar_infos_item_cardapio
	retornar_infos_item_cardapio_item_nao_encontrado:
		addi $v0, $0, -1 #C�digo de falha
		addi $v1, $0, -1 #C�digo de falha
fim_retornar_infos_item_cardapio:
jr $ra #Return ($v0 -> pre�o do item, caso o item n�o exista, $v0 ter� o valor de -1 | int .half
			#$v1 -> Vai apontar exatamente para o inicio da string, caso o item n�o exista, o seu valor ser� -1 | address int)

#Deslocar uma quantidade N ($a1 - $a0) de bytes para a esquerda ($a2)
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

end_cardapio:

#=====Acessar um item do card�pio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra

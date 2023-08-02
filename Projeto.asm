.data
#===== Bits reservados para cada item do cardápio =====
	#codigo do cardápio -> 1-20          = 5   bits(2^5 = 32 valores)        arredondando para words = 16bits    unsigned
	#preco (centavos)    -> 0-99999  =  14 bits(2^14 = 16384 valores) arredondando para bytes = 16bits  unsigned
	#descricao (letras) -> 0-60         =  60*8 = 480 bits 			   arredondando para bytes = 480bits unsigned
#Bits totais para um item do cardápio = 16 + 16 + 480 = 512 bits -> 64 bytes

#Espacos totais para os 20 itens do cardápio 64x20 = 1.280
cardapio: .space 1280					    #bytes -> quantidade em bytes reservados para todos os possiveis 20 itens do cardápio
#Valores extras para o funcionamento do cardapio
tamanho_total_cardapio: .word 1280		  # int -> tamanho total do cardápio em bytes
limite_cardapio: .half 20   		                   #int -> indica qual o limite de itens do cardápio
ponteiro_cardapio: .half 0 		                   #int -> Sempre vai estar apontando para a proxima posição livre do cardapio. Quando chega em limite_cardapio, indica que a proxima posição livre está fora do espaço reservado.
tamanho_codigo_item_cardapio: .byte 2          #int -> indica o tamanho em bytes reservados para o código do cardápio
tamanho_preco_item_cardapio: .byte 2 	  #int -> indica o tamanho em bytes reservados para o código do cardápio
tamanho_descricao_item_cardapio: .byte 60 #int -> indica o tamanho em bytes reservados para a descrição do item do cardápio 
tamanho_total_item_cardapio: .byte 64        #int -> indica o tamanho em bytes reservados para um item do cardápio

#Mesas
# ===== Bits reservados para cada item da mesa =====
# codigo da mesa -> 01-15        = 4 bits (2^4 = 16 valores)    arredondando para words = 8 bits    unsigned
# telefone        -> DDDNNNNNNNN = 11 dígitos                 arredondando para bytes = 11 bytes  ASCII (ou outra codificação)
# responsavel     -> 0-60        = 60*8 = 480 bits            arredondando para bytes = 480 bits  ASCII (ou outra codificação)

# Bits totais para um item da mesa = 8 + 11*8 + 480 = 488 bits -> 61 bytes

# Espaços totais para as 15 mesas: 61 * 15 = 915 bytes
mesas: .space 915 #bytes -> quantidade em bytes reservados para os possíveis 15 itens das mesas
#textos reservados
falha_criacao_item_cardapio_codigo_cadastrado: .asciiz "Falha: numero de item ja cadastrado\n"
falha_criacao_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"
falha_criacao_item_cardapio_cheio: .asciiz "Falha: cardapio cheio\n"

falha_remover_item_cardapio_codigo_nao_cadastrado: .asciiz "Falha: codigo informado nao possui item cadastrado no cardapio\n"
falha_remover_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"

aviso_listar_cardapio: .asciiz "Aviso: o cardapio nao possui nenhum item cadastrado ainda\n"

line_breaker: .asciiz"\n"
string_codigo_do_item: .asciiz"Codigo do item: "
string_valor_do_item: .asciiz"Valor do item: "
string_descricao_do_item: .asciiz"Descricao do item: "
string_codigo_da_mesa: .asciiz"Codigo da mesa: "
string_telefone_do_responsavel: .asciiz"Telefone do responsavel da mesa: "
string_nome_responsavel_da_mesa: .asciiz"Nome do responsavel da mesa: "
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

#testes
string_usuario: .space 60
input_string_usuario: .asciiz"Digite um comentário para o item por favor: "
telefone_teste_usuario: .asciiz"81992248823"
nome_teste_usuario: .asciiz"Jacinto Pinto"

.text
main:
#inicando uma mesa
    	# $a0 - Código da mesa (01 a 15)
    	# $a1 - Telefone do responsável (string com 11 caracteres)
    	# $a2 - Nome do responsável (string com até 60 caracteres)
    	addi $a0, $0, 8
    	la $a1, telefone_teste_usuario
    	la $a2, nome_teste_usuario
jal mesa_iniciar

#!!!!!!!!!!!!!! INICIO DA ZONA DE TESTES !!!!!!!!!!!!!!!!!!!!!!!!!
#---Área de testes para pegar a descrição do usuário, essa parte será substituida com o CLI posterior, mas por agora para se adicionar um item no cardápio, é preciso ler essa string
addi $v0, $0, 4 #Printar String
la $a0, input_string_usuario
syscall

la $a0, string_usuario #carrega o endereço de string em $a0 para ser utilizado na leitura (saber onde vai começar a armazenar os caracteres?)
addi $a1, $0, 60 #carregando o maximo de caracteres para leitura
addi $v0,$0, 8 # Serviço 8 lê uma string
syscall
add $a2, $0, $a0 #armazena o valor lido em $a2 (string do usuario) 
#OBS: A descrição dos itens por enquanto é a mesma para todos eles, já que estamos pegando apenas uma única string para isso

#---Valores de teste referentes ao id do item ($a0) e ao preço dele ($a1)
addi $a0, $0, 1
addi $a1, $0, 1000
jal cardapio_ad
jal cardapio_ad #Erro: Item já cadastrado
jal cardapio_ad #Erro: Item já cadastrado

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
jal cardapio_ad # Erro: Código inválido

addi $a0, $0, 0
addi $a1, $0, 78214
jal cardapio_ad # Erro: Código inválido

#Remover item
addi $a0, $0, 21
jal cardapio_rm #Erro: código inválido

#Descomentar para testar a remoção de um item não cadastrado. Precisa comentar o código de adiçao do item de id 20
#addi $a0, $0, 20
#jal cardapio_rm #Erro: código não cadastrado

addi $a0, $0, 20 #testando a remoção do ultimo item
jal cardapio_rm #Sucesso

addi $a0, $0, 19 #testando a remoção do ultimo item (mas não no limite)
jal cardapio_rm #Sucesso

addi $a0, $0, 4 #testando a remoção de um item aleatorio
jal cardapio_rm #Sucesso

addi $a0, $0, 1 #testando a remoção do primeiro item
jal cardapio_rm #Sucesso

#Adicionando um item após uma deleção
addi $a0, $0, 19 #testando a adição de um item após uma remoção
addi $a1, $0, 12394
jal cardapio_ad #Sucesso

addi $a0, $0, 20 #testando a adição de um item após uma remoção
addi $a1, $0, 11111
jal cardapio_ad #Sucesso

addi $a0, $0, 4 #testando a adição de um item após uma remoção
addi $a1, $0, 74848
jal cardapio_ad #Sucesso

addi $a0, $0, 4 #testando a adição de um item após uma remoção
addi $a1, $0, 73748
jal cardapio_ad #Erro: Item já cadastrado

addi $a0, $0, 1 #testando a adição de um item após uma remoção
addi $a1, $0, 68356
jal cardapio_ad #Sucesso

#Checando a existencia de um código no cardápio
addi $a0, $0, 3
addi $a1, $0, 1600
jal checar_existencia_de_codigo #Retorna 1 (código encontrado)

#Checando o print do cardápio
jal cardapio_list #Sucesso


#inicando uma mesa
    	# $a0 - Código da mesa (01 a 15)
    	# $a1 - Telefone do responsável (string com 11 caracteres)
    	# $a2 - Nome do responsável (string com até 60 caracteres)
    	addi $a0, $0, 1
    	la $a1, telefone_teste_usuario
    	la $a2, nome_teste_usuario
jal mesa_iniciar

addi $a0, $0, 1
jal print_mesa_data

#Encerrar programa
addi $v0, $0, 10
syscall


#Funções============================================================================================================================================================
#=====Criar item no cardápio=====
cardapio_ad: #Params ($a0 -> codigo do item  | int          2 bytes,
				     #$a1 ->  preco do item   | int        2 bytes,
				     #$a2 -> descricao	    | string 60 bytes)
	#Registradores temporarios utilizados:
	#$t0 -> limite_cardapio
	#$t1 -> endereço do ponteiro_cardapio
	#$t2 -> valor do ponteiro_cardapio
	#$t3 -> endereço inicial do proximo espaço livre de item de cardápio
	#$t4 -> total de bytes do item do cardapio
	#$t5 -> Um faz tudo
	
	#Checando para ver se o codigo do cardapio ja nao foi inserido
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_existencia_de_codigo #recebendo $a0 como entrada (código do item a ser adicionado) para ver se ele já existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	bnez $v0, falha_cardapio_codigo_existe #if (checar_existencia_de_codigo != 0) {return erro} 
	
	#=============================================
	lhu $t0, limite_cardapio
	la $t1, ponteiro_cardapio
	lhu $t2, ponteiro_cardapio
	lbu $t4, tamanho_total_item_cardapio
	
	#Checando para ver se o código digitado está entre 1-20
	bge $a0, 1, checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_codigo_alcance  # Pula para o final da função

	checar_limite_superior:
	ble $a0, $t0, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele está dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da função
	
	dentro_do_limite:
	#Checando para ver se o cardápio já não está cheio		
	beq $t0, $t2, falha_cardapio_cheio

	#Adicionando o item no cardapio
	la $t3, cardapio 	#Carregando o endereço inicial do cardapio
	multu $t2,$t4 	#Calculando o offset para se chegar no proximo espaço de memória livre reservado para um item (67 bytes). ponteiro_cardapio * tamanho_total_item_cardapio 
	mflo $t5 			#$t5 recebe o resultado da multiplicação anterior
	add $t3, $t3, $t5  #adiciona o offset necessário calculado anteriormente com o valor base do cardápio, assim iremos diretamente para o proximo espaço vazio da lista.
	sh $a0, 0($t3)     	#Salva o byte referente ao código do item do cardapio na primeira posição 
	
	lb $t5, tamanho_codigo_item_cardapio #Carrega o valor reservado de bytes para o código do cardápio em $t5
	add $t3, $t3, $t5  #soma o valor atual do offset com o valor reservado de bytes para o código do cardápio, fazendo com que $t3 fique apontando para o espaço vazio reservado ao preço do item
	sh $a1, 0($t3)		#Salva o half referente ao preço do item do cardápio na posição depois do código do pedido
	
	lb $t5, tamanho_preco_item_cardapio #Carrega o valor reservado de bytes para o preço do cardápio em $t5
	add $t3, $t3, $t5  #soma o valor atual do offset com o valor reservado de bytes para o preço do cardápio, fazendo com que $t3 fique apontando para o espaço vazio reservado a descrição do item
	
	addi $t2, $t2, 1	#Acrescenta 1 ao ponteiro_cardapio
	sh $t2, 0($t1) 	#armazena o valor ponteiro_cardapio + 1 no endereço do ponteiro_cardapio
	
	add $a3, $0, $t3   #Carregando o endereço destino da cópia de string para $a3
	#a2 já possui o valor da string que queremos copiar para $a3
	addi $sp, $sp, -4 #Reservando espaço na memória para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da cópia
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	j sucesso
	
	falha_cardapio_cheio:
		print_string(falha_criacao_item_cardapio_cheio)
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_ad
		
	falha_cardapio_codigo_existe:
		print_string(falha_criacao_item_cardapio_codigo_cadastrado)
		addi $v0, $0, 1
		j fim_cardapio_ad
		
	falha_cardapio_codigo_alcance:
		print_string(falha_criacao_item_cardapio_codigo_invalido)
		addi $v0, $0, 1
		j fim_cardapio_ad
	sucesso:
		addi $v0, $0, 0
	fim_cardapio_ad:
jr $ra		#Return ($v0 -> sucesso(0)/fracasso(1) | bool)


#===== Deletar item do cardápio =====
cardapio_rm:  #Params ($a0 -> codigo do item  | int  2 byts)

	#Checando para ver se o código digitado está entre 1-20
	bge $a0, 1, rm_checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_rm_codigo_alcance  # Pula para o final da função
	rm_checar_limite_superior:
	ble $a0, $t0, rm_dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele está dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da função
	rm_dentro_do_limite:
	
	#Checando para ver se o código existe dentro do cardápio
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_existencia_de_codigo #verificar se o código inserido realmente existe no cardápio
	lw $ra, 0($sp)	#Recupenrando o $ra  antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	beqz $v0, falha_cardapio_rm_codigo_inexistente #Se o retorno de checar_existencia_de_codigo for 0, significa que o código inserido não existe
	
	#Caso o código seja válido e exista, vamos "Deletar a entrada" movendo todos os bytes a direita desse item do cardápio para a esquerda. Caso seja o ultimo item, apenas zeramos sua entrada
	addi $sp, $sp, -16
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	sw $a0, 4($sp)#Salvando o valor de $a0
	sw $a1, 8 ($sp)#Salvando o valor de $a1
	sw $a2, 12($sp)#Salvando o valor de $a2
	la $t4, cardapio
	lbu $t0, tamanho_total_item_cardapio #Carregando o tamanho total de um item no cardapio
	multu $v1, $t0 # Calculando o offset necessário para ir diretamente para a primeira posição do item que será "deletado"
	mflo $t1          #offset para se chegar no item que vai ser "deletado"
	add $a2, $t4, $t1 #a2 está apontando exatamente para o local inicial onde o conjunto vai ser copiado (apontando para o item que vai ser "deletado")
	add $a0, $a2, $t0 # $a0 será o proximo item referente ao item que vai ser "deletado"
	lw $t2, tamanho_total_cardapio 
	add $a1, $t2, $t4 #Calculando o endereço final do cardápio
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
	sh $t2, 0($t1) 	#armazena o valor ponteiro_cardapio - 1 no endereço do ponteiro_cardapio
	
	addi $v0, $0, 0 	#sucesso
	
	j fim_cardapio_rm
	falha_cardapio_rm_codigo_inexistente:
		print_string(falha_remover_item_cardapio_codigo_nao_cadastrado)
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_rm
	falha_cardapio_rm_codigo_alcance:
		print_string(falha_remover_item_cardapio_codigo_invalido)
		addi $v0, $0, 1 #1 significa falha
		j fim_cardapio_rm
fim_cardapio_rm: 
jr $ra	       #Return ($v0 -> sucesso (0)/fracasso(1) | bool)


#===== Chegar se um id especifico já está no cardapio ===== 
checar_existencia_de_codigo: #Params($a0 -> codigo do item | int)
	#Registradores temporarios utilizados:
	#$t3 -> Código do atual item sendo lido
	#$t4 -> contador de itens de cardapio ja percorridos
	#$t5 -> ponteiro_cardapio
	#$t6 -> registrador que vai percorrer de código em código
	#$t7 -> tamanho total de um item no cardápio (utilizado para fazer os devidos offsets)
	addi $t4, $0, 0
	lb $t5, ponteiro_cardapio
	la $t6, cardapio 
	lb $t7, tamanho_total_item_cardapio
	
	beq $t5, $0, nao_existe #if (ponteiro_cardapio == 0) {return 0}
	loop_checagem:
		beq $t4, $t5, nao_existe #if (contador_itens == qnt_itens) {return 0}  Isso significa que, se tivermos percorrido todos os itens e não achamos um código igual, retornamos zero
		lhu $t3, ($t6) #Como $t6 sempre vai estar apontando para o primeiro byte do item do cardápio, $t6 sempre vai estar apontando para o código daquele item
		beq $a0, $t3, existe	#if (codigo_atual == codigo_parametro) {return 1}
		addi $t4, $t4, 1	#adiciona mais um ao contador de itens do cardapio
		add, $t6, $t6, $t7 #adicionando o offset a $t6 para que ele vá para o proximo código do proximo item
		j loop_checagem
	nao_existe:
		addi $v0, $0, 0
		addi $v1, $0, -1
		j fim_checar_existencia_de_codigo 
	existe:
		addi $v0, $0, 1
		add $v1, $0, $t4 #salvando o valor do contador em $v1, assim $v1 vai retornar a posição onde esse item foi encontrado
	fim_checar_existencia_de_codigo:
jr $ra # Return($v0 -> 1 se o código já existe e 0 caso ele não exista | bool
			#$v1 -> Posição no cardápio onde esse item foi encontrado, caso não tenha sido encontrado, o seu valor será -1 | int)


#Deslocar uma quantidade N ($a1 - $a0) de bytes para a esquerda ($a2)
shift_mem_left: #Params ($a0 -> local inicial do conjunto de bytes que vai ser copiado | memory address,
					 # $a1 -> local final do conjunto de bytes que vai ser copiado   | memory address,
					 # $a2 -> local inicial para onde o conjunto vai ser copiado       | memory address)
	#Registradores temporarios utilizados:
	#$t0 -> vai percorrer o conjunto de bits e vai copia-los
	#$t1 -> vai percorrer, junto com o $t0 e vai servir para $t0 copiar o byte para $t1
	#$t2 -> byte que estará na posição $t0
	add  $t0, $0, $a0 # começa no valor inicial de copia
	add $t1, $0, $a2 # começa nop valor inicial do destino
	lb $t2, 0($t0)
	#no nosso caso, se $a0 (restante do cardapio) for igual a $a1 (final do cardapio) significa que estamo removendo o ultimo elemento, e, se isso for verdade, faremos uma abordagem diferente
	beq $a0, $a1, shift_mem_left_caso_ultimo_elemento

	loop_shift_mem_left:
		beq $t0, $a1, fim_shift_mem_left
		sb $t2, 0($t1) #copiando o byte para o destino a esquerda
		sb $0, 0($t0) #apagando o conteudo anterior, já que ele já foi copiado
		addi $t0, $t0, 1 #indo para o próximo endereço de memória
		addi $t1, $t1, 1 #indo para o próximo endereço de memória
		lb $t2, 0($t0) #carregando o proximo byte
		j loop_shift_mem_left
	
	shift_mem_left_caso_ultimo_elemento:
		loop_shift_mem_left_ultimo_elemento:
			beq $t1,  $a1, fim_shift_mem_left #caso tenhamos chegado no final ($a1) encerramos
			#enquanto não encerramos, percorremos byte a byte, transformando todos os bytes em 0
			sb $0, 0($t1) #zeramos o byte
			addi $t1, $t1, 1 #passamos para o proximo
			j loop_shift_mem_left_ultimo_elemento
fim_shift_mem_left:
jr $ra		   #Return (None)

#===== Copiar String ===== 
strcpy:	#função que copia uma string
	move $t0, $a3 #tirando os endereços das registradores de parametro e colocando em registradores temporarios
	move $t1, $a2
	move $v0, $t0 #salvando o endereço destino para retornar no final da função
	loop:
		lb $t2, ($t1) #carrega 1 bit da memoria em $t2 da string origem
		beqz $t2, exit_strcpy #compara $t2 com zero para saber se ja chegou ao fim da string
		sb $t2, ($t0) #guarda na memoria destino o bit em $t2
		addi $t0, $t0, 1 #incrementa o endereço de memoria
		addi $t1, $t1, 1
		j loop
	exit_strcpy:
		#sb $zero, 1($t0) #adiciona o zero ao final da string
jr $ra


#===== Listar todos os itens do cardápio em ordem crescente por código =====
cardapio_list: #Params (None)
	#Registradores temporários utilizados:
	#$t0 -> ponteiro_cardapio
	#$t1 -> limite_cardapio
	#$t2 -> vai de 1 em 1 até o limite do cardápio (quantidade de códigos), assim assegurando que a ordem com que os itens serão mostrados será a ordem crescente.
	#$t3 -> faz tudo 1
	#$t4 -> faz tudo 2
	addi $sp, $sp, -8
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	sw $ra, 4($sp) #Salvando o valor de $ra já que chamaremos mais uma função dentro dessa mesma função
	lhu $t0, ponteiro_cardapio
	lhu $t1, limite_cardapio
	addi $t2, $0, 1
	beq $t0, $0, aviso_cardapio_list #Se a lista estiver vazia, retornar apenas o aviso
	
	loop_cardapio_list:
		bgtu $t2, $t1, fim_cardapio_list  #se $t2 ultrapassar o limite do cardapio, indica que já esgotamos todos os possiveis prints de itens
		add $a0, $0, $t2 #copiando o atual valor de $t2 para servir de entrada para a função de checagem
		jal checar_existencia_de_codigo #Params($a0 -> codigo do item | int)
		beq $v0, 0, nao_fazer_print_cardapio_list #se a checagem tiver um retorno negativo (0), então não vamos printar do elemento
		#caso contrário, vamos printar o elemento
		add $t3, $0, $v1 #armazenando o index do item achado em $t5
		lbu $t4, tamanho_total_item_cardapio #carrega o tamanho de um item em $t4
		multu $t3, $t4
		mflo $t3 #$t3 armazena o offset necessário para se chegar ao item
		la $t4, cardapio
		#Printando o código do item
		add $t4, $t4, $t3 #E com essa soma chegamos exatamente a posição de memória do item do cardápio
		lhu $t3, 0($t4) #Carregando o valor do código do item
		 print_string(string_codigo_do_item)
		 print_int($t3)
		 print_string(line_breaker)
		 #Printando o preço do item
		 lbu $t3, tamanho_codigo_item_cardapio #Carregando o tamanho do código do item
		 add $t4, $t3, $t4 #Somando o local da memória com o tamanho do código, fazendo com que $t4 esteja agora no preço do item
		 lhu $t3, 0($t4) #Carregando o valor do preço do item
		 print_string(string_valor_do_item)
		 print_int($t3)
		 print_string(line_breaker)
		 #Printando a descrição do item
		 lbu $t3, tamanho_preco_item_cardapio #Carregando o tamanho do preço do item
		 add $t4, $t3, $t4 #Somando o local da memória com o tamanho do preço, fazendo com que $t4 esteja agora na descrição
		 print_string(string_descricao_do_item)
		 #não utilizei o macro já que ele carrega um  endereço dentro ele, e, $t4 já possui um endereço
		addi $sp, $sp, -4
		sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
		addi $v0, $0, 4
		add $a0, $0, $t4
		syscall
		lw $a0, 0($sp)	#Recuperando o $a0 antigo
		addi $sp, $sp, 4 #voltando a pilha pro lugar original
		 print_string(line_breaker)
		 
		nao_fazer_print_cardapio_list:	
			addi $t2, $t2, 1 #incrementando o valor de $t2 até chegar no limite do cardápio ($t1)
			j loop_cardapio_list
	 aviso_cardapio_list:
	 	print_string(aviso_listar_cardapio)
	 	
	fim_cardapio_list:
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $ra original para poder sair dessa função
	addi $sp, $sp, 8 #voltando a pilha pro lugar original
         jr $ra
         
         
	mesa_iniciar:
    	# Exemplo de chamada para iniciar o atendimento em uma mesa (mesa_iniciar):
    	# Registros de entrada:
    	# $a0 - Código da mesa (01 a 15)
    	# $a1 - Telefone do responsável (string com 11 caracteres)
    	# $a2 - Nome do responsável (string com até 60 caracteres)
    	# Registros de saída:
    	# $v0 - Resultado da operação (0 para sucesso, -1 para falha)

    # Valida se o código da mesa é válido (01 a 15)
    li $t0, 1        # Carrega 1 em $t0 (valor mínimo do código da mesa)
    li $t1, 15       # Carrega 15 em $t1 (valor máximo do código da mesa)
    blt $a0, $t0, mesa_inexistente   # Se $a0 < 1, a mesa é inexistente
    bgt $a0, $t1, mesa_inexistente   # Se $a0 > 15, a mesa é inexistente

    # Calcula o endereço na memória para o item da mesa
    # Cada item possui 61 bytes, então o endereço é calculado como: endereço_base + (tamanho_do_item * (codigo_da_mesa - 1))
    li $t2, 61       # Carrega 61 em $t2 (tamanho do item da mesa)
    sub $t3, $a0, 1  # Subtrai 1 do código da mesa para obter o índice baseado em 0
    mul $t3, $t3, $t2  # Multiplica o índice pelo tamanho do item para obter o deslocamento
    la $t4, mesas    # Carrega o endereço base da memória para as mesas em $t4
    add $t4, $t4, $t3  # Calcula o endereço do item da mesa

    # Verifica se a mesa está ocupada (o primeiro byte do item da mesa é usado para esse propósito)
    lb $t5, 0($t4)   # Carrega o primeiro byte do item da mesa em $t5
    bnez $t5, mesa_ocupada   # Se o byte não é zero, a mesa está ocupada

    # Mesa disponível para iniciar o atendimento
    # Define o estado da mesa como ocupada (define o primeiro byte como 1)
    li $t5, 1        # Carrega 1 em $t5 (valor para mesa ocupada)
    sb $t5, 0($t4)   # Armazena o valor em $t5 no primeiro byte do item da mesa

    # Armazena o telefone e o nome do responsável na memória (a partir do segundo byte)
    move $t6, $a1    # Move o telefone do responsável para $t6
    move $t7, $a2    # Move o nome do responsável para $t7
    sw $t6, 4($t4)   # Armazena o telefone no segundo byte do item da mesa
    sw $t7, 16($t4)  # Armazena o nome do responsável a partir do 12º byte do item da mesa

    # Atendimento iniciado com sucesso
    li $v0, 0        # Define $v0 como 0 (para sucesso)
    
    # Imprime o código da mesa
   # li $v0, 1           # Código da syscall para imprimir inteiro
    #move $a0, $t8       # Carrega o código da mesa em $a0
    #syscall
   print_string(string_codigo_da_mesa)
		print_int($t8)
		 print_string(line_breaker)

print_string(string_telefone_do_responsavel)
    # Imprime o telefone do responsável
    li $v0, 4           # Código da syscall para imprimir string
    move $a0, $t6       # Carrega o telefone do responsável em $a0
syscall
    
    
print_string(line_breaker)
print_string(string_nome_responsavel_da_mesa)
    # Imprime o nome do responsável
    li $v0, 4           # Código da syscall para imprimir string
    move $a0, $t7       # Carrega o nome do responsável em $a0
    syscall
    
    jr $ra
    mesa_inexistente:
    # Mesa inexistente
    li $v0, -1       # Define $v0 como -1 (para falha)
    jr $ra
    mesa_ocupada:
    # Mesa ocupada
    li $v0, -2       # Define $v0 como -2 (para falha)
    jr $ra
    
    # Função para imprimir os dados da mesa
# Recebe o código da mesa em $a0
print_mesa_data:
    # Calcula o endereço base do array de mesas
    la $t0, mesas

    # Calcula o deslocamento no array de mesas com base no código da mesa
    sll $t1, $a0, 6    # Cada entrada de mesa ocupa 64 bytes (2^6)
    add $t0, $t0, $t1  # $t0 = endereço base + deslocamento

    # Imprime o código da mesa
    li $v0, 1           # Código da syscall para imprimir inteiro
    lw $a0, 0($t0)      # Carrega o código da mesa em $a0
    syscall

    # Imprime o telefone do responsável
    li $v0, 4           # Código da syscall para imprimir string
    lw $a0, 4($t0)      # Carrega o telefone do responsável em $a0
    syscall

    # Imprime o nome do responsável
    li $v0, 4           # Código da syscall para imprimir string
    lw $a0, 16($t0)      # Carrega o endereço do nome do responsável em $a0
    syscall

    jr $ra              # Retorna para o chamador
jr $ra #Return (None)
#=====Acessar um item do cardápio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra
	
	

.data
#===== Bits reservados para cada item do cardápio =====
	#codigo do cardápio -> 1-20          = 5   bits(2^5 = 32 valores)        arredondando para words = 16bits    unsigned
	#preco (centavos)    -> 0-99999  =  14 bits(2^14 = 16384 valores) arredondando para bytes = 16bits  unsigned
	#descricao (letras) -> 0-60         =  60*8 = 480 bits 			   arredondando para bytes = 480bits unsigned
#Bits totais para um item do cardápio = 16 + 16 + 480 = 512 bits -> 64 bytes

#Espacos totais para os 20 itens do cardápio 64x20 = 1.280
cardapio: .space 1280					    #bytes -> quantidade em bytes reservados para todos os possiveis 20 itens do cardápio
#Valores extras para o funcionamento do cardapio
limite_cardapio: .half 20   		                   #int -> indica qual o limite de itens do cardápio
ponteiro_cardapio: .half 0 		                   #int -> Sempre vai estar apontando para a proxima posição livre do cardapio. Quando chega em limite_cardapio, indica que a proxima posição livre está fora do espaço reservado.
tamanho_codigo_item_cardapio: .byte 2          #int -> indica o tamanho em bytes reservados para o código do cardápio
tamanho_preco_item_cardapio: .byte 2 	  #int -> indica o tamanho em bytes reservados para o código do cardápio
tamanho_descricao_item_cardapio: .byte 60 #int -> indica o tamanho em bytes reservados para a descrição do item do cardápio 
tamanho_total_item_cardapio: .byte 64        #int -> indica o tamanho em bytes reservados para um item do cardápio

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
#---Área de testes para pegar a descrição do usuário, essa parte será substituida com o CLI posterior, mas por agora para se adicionar um item no cardápio, é preciso ler essa string
la $a0, string_usuario #carrega o endereço de string em $a0 para ser utilizado na leitura (saber onde vai começar a armazenar os caracteres?)
addi $a1, $0, 60 #carregando o maximo de caracteres para leitura
addi $v0,$0, 8 # Serviço 8 lê uma string
syscall
add $a2, $0, $a0 #armazena o valor lido em $a2 (string do usuario) 
#OBS: A descrição dos itens por enquanto é a mesma para todos eles, já que estamos pegando apenas uma única string para isso

#---Valores de teste referentes ao id do item ($a0) e ao preço dele ($a1)
addi $a0, $0, 1
addi $a1, $0, 1000
jal cardapio_add
jal cardapio_add #Erro: Item já cadastrado
jal cardapio_add #Erro: Item já cadastrado

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
jal cardapio_add # Erro: Código fora do alcance

addi $a0, $0, 0
addi $a1, $0, 78214
jal cardapio_add # Erro: Código fora do alcance


#Checando a existencia de um código no cardápio
addi $a0, $0, 3
jal checar_existencia_de_codigo #Retorna 1 (código encontrado)

#Encerrar programa
addi $v0, $0, 10
syscall

#=====Criar item no cardápio=====
cardapio_add: #Params ($a0 -> codigo do item  | int        1 byte,
				     #$a1 ->  preco do item   | int        2 bytes,
				     #$a2 -> descricao	    | string 64 bytes)
	#Registradores temporarios utilizados:
	#$t0 -> limite_cardapio
	#$t1 -> endereço do ponteiro_cardapio
	#$t2 -> valor do ponteiro_cardapio
	#$t3 -> endereço inicial do proximo espaço livre de item de cardápio
	#$t4 -> total de bytes do item do cardapio
	#$t5 -> Um faz tudo
	
	#==Checando para ver se o codigo do cardapio ja nao foi inserido
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
	
	#== Checando para ver se o código digitado está entre 1-20
	bge $a0, 1, checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_codigo_alcance  # Pula para o final da função

	checar_limite_superior:
	ble $a0, $t0, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele está dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da função
	
	dentro_do_limite:
	#==Checando para ver se o cardápio já não está cheio		
	beq $t0, $t2, falha_cardapio_cheio

	#==Adicionando o item no cardapio
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

	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da cópia
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
		lh $t3, ($t6) #Como $t6 sempre vai estar apontando para o primeiro byte do item do cardápio, $t6 sempre vai estar apontando para o código daquele item
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
			#$v1 -> Posição no cardápio onde esse item foi encontrado | int)

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

#=====Acessar um item do cardápio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra


#======================Parse da String=================



parse_string: #função que separa a string informada em paramentros ($a0, $a1, $a2, $a3) e pula diretamente para a função informada na String
		  #ao fim
	#codigo dos char: (- = 45) ( _ = 95) (a = 97) (c = 99) (f = 102) (l = 108) (r = 114) 
	add $t0, $0, $a0 #movendo o endereço base da String para $t0
	add $t1, $0, $0 #registrador auxiliar que indica qual argumento foi encontrado
	parse_string_loop:
		lb $t2, 0($t0) #carregando o byte atual
		beq $t2, 0, parse_string_fim #verifica se a String chegou ao final
		beq $t2, 45, parse_string_achou #verifica se chegou ao primeiro argumento
		addi $t0, $t0, 1 #somando 1 ao endereço base
		j parse_string_loop #reinicia o loop
	
	parse_string_achou:
		addi $t0, $t0, 1
		beq $t1, 0, parse_string_achou0
		beq $t1, 1, parse_string_achou1
		beq $t1, 2, parse_string_achou2
		
		parse_string_achou0:
		add $a0, $t0, $0
		parse_string_achou1:
		parse_string_achou2:

	parse_string_fim:
		#codigo que vai direcionar para onde o programa vai :)
	

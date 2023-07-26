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
ponteiro_cardapio: .half 0 		                   #int -> indica quantos itens existem atualmente no cardápio (vai até limite_cardápio - 1) 
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
#---Área de testes para pegar a descrição do usuário, essa parte será substituida com o CLI posterior, mas por agora para se adicionar um item no cardápio, é preciso ler essa string
la $a0, string_usuario #carrega o endereço de string em $a0 para ser utilizado na leitura (saber onde vai começar a armazenar os caracteres?)
addi $a1, $0, 60 #carregando o maximo de caracteres para leitura
addi $v0,$0, 8 # Serviço 8 lê uma string
syscall
add $a2, $0, $a0 #armazena o valor lido em $a2 (string do usuario) 
#---

#---Valores de teste referentes ao id do item ($a0) e ao preço dele ($a1)
addi $a0, $0, 15
addi $a1, $0, 5678
#---

jal cardapio_add
jal cardapio_add
jal cardapio_add
jal cardapio_add
jal cardapio_add
jal cardapio_add
addi $v0, $0, 10
syscall
#=====Criar item no cardápio=====
cardapio_add: #Params ($a0 -> codigo do item  | int        1 byte,
				     #$a1 ->  preco do item   | int        2 bytes,
				     #$a2 -> descricao	    | string 64 bytes)
	#$t0 -> limite_cardapio
	#$t1 -> endereço do ponteiro_cardapio
	#$t2 -> valor do ponteiro_cardapio
	#$t3 -> endereço inicial do proximo espaço livre de item de cardápio
	#$t4 -> total de bytes do item do cardapio
	lhu $t0, limite_cardapio
	la $t1, ponteiro_cardapio
	lhu $t2, ponteiro_cardapio
	lbu $t4, tamanho_total_item_cardapio
	#==Checando para ver se o cardápio já não está cheio		
	beq $t0, $t1, falha_cardapio_cheio

	#==Checando para ver se o codigo do cardapio ja nao foi inserido
	#======================TO DO=======================
	
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
	sh $t2, 0($t1) 		#armazena o valor ponteiro_cardapio + 1 no endereço do ponteiro_cardapio
	
	add $a3, $0, $t3   #Carregando o endereço destino da cópia de string para $a3
	#a2 já possui o valor da string que queremos copiar para $a3

	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da cópia
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	j sucesso
	
	falha_cardapio_cheio:
		print_string(falha_criacao_item_cardapio_cheio)
		addi $v0, $0, 1
	sucesso:
jr $ra		#Return ($v0 -> sucesso(0)/fracasso(1) | bool

strcpy:	#função que copia uma string
	move $t0, $a3 #tirando os endereços das registradores de parametro e colocando em registradores temporarios
	move $t1, $a2
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

#=====Acessar um item do cardápio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra
	
	

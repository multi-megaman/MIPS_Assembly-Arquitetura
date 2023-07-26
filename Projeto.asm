.data
#===== Bits reservados para cada item do cardápio =====
	#codigo do cardápio -> 1-20          = 5   bits(2^5 = 32 valores)        arredondando para bytes = 8bits    unsigned
	#preco (centavos)    -> 0-99999  =  14 bits(2^14 = 16384 valores) arredondando para bytes = 16bits  unsigned
	#descricao (letras) -> 0-64         =  64*8 = 512 bits 			   arredondando para bytes = 512bits unsigned
#Bits totais para um item do cardápio = 8 + 16 + 512 = 536 bits -> 67 bytes

#Espacos totais para os 20 itens do cardápio 67x20 = 1.340
cardapio: .space 1340
limite_cardapio: .half 20   #int -> indica qual o limite de itens do cardápio
ponteiro_cardapio: .half 0 #int -> indica quantos itens existem atualmente no cardápio (vai até limite_cardápio - 1) 

#textos reservados
falha_criacao_item_cardapio_codigo_cadastrado: .asciiz "Falha: numero de item ja cadastrado\n"
falha_criacao_item_cardapio_codigo_invalido: .asciiz "Falha: codigo de item invalido\n"
falha_criacao_item_cardapio_cheio: .asciiz "Falha: cardapio cheio\n"


.macro print_string(%string)
	addi $v0, $0, 4
	la $a0, %string
	syscall
.end_macro
.text
main:

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
	lhu $t0, limite_cardapio
	la $t1, ponteiro_cardapio
	lhu $t2, ponteiro_cardapio
	#==Checando para ver se o cardápio já não está cheio		
	beq $t0, $t1, falha_cardapio_cheio

	#==Checando para ver se o codigo do cardapio ja nao foi inserido
	#======================TO DO=======================
	
	#==Adicionando o item no cardapio
	
	addi $t2, $t2, 1
	sh $t2, $t1 #armazena o valor ponteiro_cardapio + 1 no endereço do ponteiro_cardapio
	j sucesso
	
	falha_cardapio_cheio:
		print_string(falha_criacao_item_cardapio_cheio)
		addi $v0, $0, 1
	sucesso:
jr $ra		#Return ($v0 -> sucesso(0)/fracasso(1) | bool

#=====Acessar um item do cardápio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra
	
	

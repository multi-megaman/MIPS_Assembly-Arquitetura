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

string_teste_parse: .asciiz "cardapio_ad-15-00490-coca cola" #vai servir para testar o parse da string

.text
main:
#j parse_string_testes #vai pular diretamente para a area do parse da String
la $a0, string_teste_parse
j parse_string

zona_testes_parse_string:

li $v0, 1
syscall

add $a0, $a1, $0
syscall

j super_hiper_end


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

jr $ra #Return (None)
#=====Acessar um item do cardápio=====
#acessar_item_cardapio: #Params ($a0 -> numero referente ao codigo do item  | int )

#jr $ra

#======================Parse da String=================
parse_string: #função que separa a string informada em paramentros ($a0, $a1, $a2, $a3) e pula diretamente para a função informada na String
	#codigo dos char: (- = 45) ( _ = 95) (a = 97) (c = 99) (f = 102) (i = 105) (l = 108) (m = 109) (0 = 111) {p = 112} (r = 114) (s = 115)
	add $t0, $0, $a0 #movendo o endereço base da String para $t0
	add $t9, $0, $a0 #salvando o endereço inicial da String em $t9 para ser usado depois da separação da String
	add $t1, $0, $0 #registrador auxiliar que indica qual argumento foi encontrado
	parse_string_loop:
		lb $t2, 0($t0) #carregando o byte atual
		beq $t2, 0, parse_string_fim #verifica se a String chegou ao final
		beq $t2, 45, parse_string_achou #verifica se chegou ao primeiro argumento esta comparando o valor carregado com "-"
		addi $t0, $t0, 1 #somando 1 ao endereço base
		j parse_string_loop #reinicia o loop
	
	parse_string_achou:
		beq $t1, 0, parse_string_achou0 #vai para a area onde será salvo o primeiro argumento
		beq $t1, 1, parse_string_achou1 #vai para a area onde será salvo o segundo argumento
		beq $t1, 2, parse_string_achou2 #vai para a area onde será salvo o terceiro argumento
		
		parse_string_achou0:
			addi $t0, $t0, 1 #adiciona 1 ao endereço atual para pegar o primeiro elemento da String e não o simbolo "-"
			add $a0, $t0, $0 #salvando o endereço base do primeiro arguemento
			addi $t1, $t1, 1 #somando 1 ao contador de argumento
			j parse_string_loop #volta pro loop
			
		parse_string_achou1:
			sb $0, 0($t0) #colocando \0 no final do argumento anterior
			addi $t0, $t0, 1 #adiciona 1 ao endereço atual para pegar o primeiro elemento da String e não o simbolo "-"
			add $a1, $t0, $0 #salvando o segundo argumento
			addi $t1, $t1, 1 #somando 1 ao contador de argumento
			j parse_string_loop #volta pro loop
			
		parse_string_achou2:
			sb $0, 0($t0) #colocando \0 no final do argumento anterior
			addi $t0, $t0, 1 #adiciona 1 ao endereço atual para pegar o primeiro elemento da String e não o simbolo "-"
			add $a2, $t0, $0 #salvando o terceiro argumento
			j parse_string_loop #volta pro loop

	parse_string_fim: #codigo que vai direcionar para onde o programa vai :)
		add $t0, $0, $t9 #movendo o endereço base da String de $t9 para #t0
		lb $t1, 0($t0) #carregando o primeiro char da String
		beq $t1, 99, parse_string_cardapio #compara o char com "c" para saber se e um comando de cardapio
		beq $t1, 109, parse_string_mesa #compara o char com "m" para saber se e um comando de mesa
		j parse_string_arquivo #como só sobrou comandos de arquivo pula diretamente
		
		parse_string_cardapio:
			addi $t0, $t0, 9 #somando 9 ao endereço pois vai direto para o char depois do "_"
			lb $t1, 0($t0)
			beq $t1, 97, parse_string_cardapio_ad #comparando com "a"
			beq $t1, 114, parse_string_cardapio_rm #comparando com "r"
			beq $t1, 108, parse_string_cardapio_list #comparando com "l"
			beq $t1, 102, parse_string_cardapio_format #comparando com f
			
			
			parse_string_cardapio_ad:
				add $a3, $a0, $0
				jal converter_string_para_int
				add $a0, $v0, $0
				add $a3, $a1, $0
				jal converter_string_para_int
				add $a1, $v0, $0
				j zona_testes_parse_string
				#j cardapio_ad 
			parse_string_cardapio_rm:
				#j cardapio_rm
			parse_string_cardapio_list:
				#j cardapio_list
			parse_string_cardapio_format:
				#j carapio_format
		
		parse_string_mesa:
			addi $t0, $t0, 5 #pula para o quinto caracter da string sendo o primeiro caracter referente ao comando da mesa
			lb $t1, 0($t0) #carrega o byte
			beq $t1, 105, parse_string_mesa_iniciar #compara com "i"
			beq $t1, 97, parse_string_mesa_ad_item #compara com "a"
			beq $t1, 114, parse_string_mesa_rm_item #compara com "r"
			beq $t1, 102, parse_string_mesa_f #compara com "f"
			beq $t1, 112, parse_string_mesa_p #compara com "p"
			
			
			
			
			
			parse_string_mesa_iniciar:
				#j mesa_iniciar
			parse_string_mesa_ad_item:
				#j mesa_ad_item
			parse_string_mesa_rm_item:
				#j mesa_rm_item
			parse_string_mesa_f:
				addi $t0, $t0, 1
				lb $t1, 0($t0)
				beq $t1, 111, parse_string_mesa_format
				#j mesa_fechar
				
				parse_string_mesa_format:
					#j mesa_format
			parse_string_mesa_p:
				addi $t0, $t0, 2
				lb $t1, 0($t0)
				beq $t1, 114, parse_string_mesa_parcial
				#j mesa_pagar
				
				parse_string_mesa_parcial:
					#j mesa_parcial
		parse_string_arquivo:
			beq $t1, 115, parse_string_arquivo_salvar
			beq $t1, 114, parse_string_arquivo_recarregar
			beq $t1, 102, parse_string_arquivo_formatar
			
			
			parse_string_arquivo_salvar:
				#j salvar
			parse_string_arquivo_recarregar:
				#j recarregar
			parse_string_arquivo_formatar:
				#j formatar

	
converter_string_para_int: #função que vai converter uma string para um inteiro recebe a String em $a3 e retorna o resultado em $v0
	add $t0, $0, $a3
	lb $t1, 0($t0)
	#falta verificar se o que foi informado é um numero
	subi $t1, $t1, 48
	
		converter_string_para_int_loop:
			addi $t0, $t0, 1
			lb $t2, 0($t0)
			beq $t2, $0, converter_string_para_int_fim
			subi $t2, $t2, 48
			mul $t1, $t1, 10
			add $t1, $t1, $t2
			j converter_string_para_int_loop
			
			
				
			converter_string_para_int_fim:
			add $v0, $t1, $0
			jr $ra	
			
super_hiper_end:

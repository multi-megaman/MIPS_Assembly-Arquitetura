.data

#Grupo: Ru-Rural
#integrantes: 
#Pedro Henrique
#Everton da Silva
#Ricardo Pompilio

#Calculando o espaco de memoria necessario para a mesa
	#Calculo para cada mesa individual:
	# Codigo da mesa -> 1-15	      = 4 bits (2^4 = 16 valores)             arredondando para bytes =  2 bytes      unsigned
	#Status da mesa -> 0-1 		      = 1 bit (ou eh 0 ou eh 1)                  arredondando para bytes =  2 bytes      unsigned
	#Nome do responsavel -> 1-60    = 61 bytes = 480 bits		     	     arredondando para bytes  =   61 bytes   unsigned
	#telefone de contato -> 11	     = 11 bytes   = 88 bits                       arredondando para bytes =   11 bytes     unsigned
	
		#Cada item pedido pela mesa
		#codigo do item -> 1-20          = 5   bits(2^5 = 32 valores)         arredondando para words = 2 bytes    unsigned
		#quantidade do item -> 0-20  = 5   bits(2^5 = 32 valores)        arredondando para words = 2 bytes    unsigned
	
	#Cada item pedido pela mesa x 20 = 80 bytes				     arredondando pra bytes = 80 bytes
	#Valor atual a ser pago (0-99.999*20) = 21 bits			              arredondando pra bytes = 4 bytes signed
	
#Calculo do espa�o do gerenciamento das 15 mesas
	# 2 (codigo) + 2 (status) + 61 (responsavel) + 11 (telefone) + 80 (registro de pedidos) + 4 (valor total) = 160 bytes para cada mesa
	# Total: 160 * 15 = 2.400 bytes
mesas_white_space: .space 38
#string_de_teste:.asciiz"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
mesas: .space 2400 #Alocando o espaco do gerenciados das XX mesas
mesas_white_space_2: .space 4

limite_cardapio: .half 20 
limite_mesas: .half 15 		                            #int -> indica qual o limite total de mesas
ponteiro_mesas: .half 0 		                            #int -> Sempre vai estar apontando para a proxima posicao livre do gerenciador de mesa. Quando chega em limite_cardapio, indica que a proxima posi��o livre estah fora do espa�o reservado.
tamanho_mesas: .half 2460 				   #Indica o tamanho total do gerenciador de mesa
tamanho_mesa: .half 160				   #Indica o tamanho total de uma unica mesa
tamanho_codigo_mesa: .byte 2			  #Indica o tamanho do codigo de uma mesa
tamanho_status_mesa: .byte 2			  #Indica o tamanho do status de uma mesa
tamanho_nome_responsavel_mesa: .half 61    #Indica o tamanho do nome do responsavel de uma mesa
tamanho_telefone_mesa: .half 11			  #Indica o tamanho do telefone de uma mesa
tamanho_codigo_item_mesa: .byte 2		 #Indica o tamanho do codigo de um unico item do cardapio
tamanho_quantidade_item_mesa: .byte 2       #Indica o tamanho da quantidade de um unico item do cardapio
tamanho_item_geral_mesa: .byte 4		#Indica o tamanho total de um �nico item do cardapio
tamanho_registro_de_pedidos: .byte 20       #Indica quantos pedidos difedentes podem ser feitos
tamanho_valor_a_ser_pago: .half 32		#Indica o tamanho do valor a ser pago

#Falhas==
falha_codigo_mesa_invalido: .asciiz "Falha: mesa inexistente\n"
falha_codigo_cardapio_invalido: .asciiz "Falha: codigo cardapio invalido\n"
falha_mesa_desocupada: .asciiz "Falha: mesa desocupada\n"
falha_mesa_ocupada: .asciiz "Falha: mesa ocupada\n"
falha_mesa_fechar: .asciiz "Falha: saldo devedor ainda nao quitado.\n"
#sucessos==
sucesso_pagamento_mesa: .asciiz "Pagamento realizado com sucesso\n"
sucesso_mesa_fechar: .asciiz "Mesa fechada com sucesso\n"
sucesso_mesa_iniciar: .asciiz "Mesa iniciada com sucesso\n"
sucesso_mesa_ad_item: .asciiz "Item adicionado com sucesso\n"
sucesso_mesa_rm_item: .asciiz "Item removido com sucesso\n"
sucesso_mesa_format: .asciiz "Mesas formatadas com sucesso\n"
#info==
line_breaker: .asciiz"\n"
mesa_parcial_string: .asciiz "Relatorio da mesa de numero "
codigo_produto: .asciiz "Codigo produto: "
quantidade_produto: .asciiz "Quantidade produto: "
valor_a_ser_pago: .asciiz "Valor a ser pago: "
valor_pago: .asciiz "Valor ja pago: "
cardapio_rs: .ascii"R$\0"
cardapio_virgula: .ascii ",\0"
#testes==
telefone_teste: .asciiz "081992248823"
nome_teste: .asciiz "Ricardo Pompilio"
#macros
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
	addi $sp, $sp, -40
	sw $a0, 0($sp) #Salvando o valor de $a0
	sw $ra, 4($sp) #Salvando o valor de $ra para poder voltar a funcao
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	sw $t3, 20($sp)
	sw $t4, 24($sp)
	sw $t5, 28($sp)
	sw $t6, 32($sp)
	sw $t7, 36($sp)
	add $a0, %number, $0
	jal print_number_on_MMIO
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $ra antigo
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	lw $t3, 20($sp)
	lw $t4, 24($sp)
	lw $t5, 28($sp)
	lw $t6, 32($sp)
	lw $t7, 36($sp)
	addi $sp, $sp, 40 #voltando a pilha pro lugar original
.end_macro

.macro macro_print_string_on_MMIO(%string)
	addi $sp, $sp, -40
	sw $a0, 0($sp) #Salvando o valor de $a0
	sw $ra, 4($sp) #Salvando o valor de $ra para poder voltar a funcao
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	sw $t3, 20($sp)
	sw $t4, 24($sp)
	sw $t5, 28($sp)
	sw $t6, 32($sp)
	sw $t7, 36($sp)
	la $a0, %string
	jal print_string_on_MMIO
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $ra antigo
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	lw $t3, 20($sp)
	lw $t4, 24($sp)
	lw $t5, 28($sp)
	lw $t6, 32($sp)
	lw $t7, 36($sp)
	addi $sp, $sp, 40 #voltando a pilha pro lugar original
.end_macro

tamanho_ate_o_registro_pedidos: .byte 76 # tamanho para o registro de pedidos
tamanho_registro_pedidos: .byte 80 # tamanho para o registro de pedidos
tamanho_ate_o_nome_responsavel: .byte 4 # tamanho para o registro de nome responsavel
tamanho_ate_o_telefone_responsavel: .byte 65 # tamanho para o registro de telefone responsavel
.text

.globl  mesa_iniciar, mesa_format, mesa_ad_item, mesa_rm_item, mesa_pagar, mesa_fechar, mesa_parcial, mesas

#jal mesa_format

#$a0 - codigo da mesa
#$a1 - telefone responsavel
#$a2 - nome responsavel
#li $a0 3
#la $a1 telefone_teste
#la $a2 nome_teste
#jal mesa_iniciar

j fim_mesas

jr $ra #Return ($v0 -> 0 para sucesso, 1 para falha | bool)

# ==== Funcao para formatar as mesas =====
mesa_format: #Params (None)
    la $t0, mesas #$t0 come�a no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
    lhu $t1, limite_mesas #$t1 define a quantidade m�xima de mesas (15)
    lbu $t2, tamanho_codigo_mesa 
    lhu $t3, tamanho_mesa
    li $t4, 1 #codigo de cada mesa, come�a em 1 e vai at� $t1 (limite_mesas)
    lbu $t5, tamanho_status_mesa
    sub $t6, $t3, $t2 #tamanho total da mesa - tamanho do codigo da mesa
    #sub $t6, $t6, $t5 # tamanho total da mesa - tamanho do codigo da mesa - tamanho da flag da mesa = quantidade de bytes restantes, onde todos esses bytes vao ser zerados
    #Interando em cada mesa
    loop_mesas_format:
        bgt $t4, $t1,end_mesa_format # se codigo da mesa > $t1 (limite_mesa), sai do loop
        sh $t4, 0($t0) #coloca codigo da mesa
        add $t0, $t0, $t2 #indo para a flag da mesa
        sh $0, 0($t0) #coloca mesa desocupada
        addi $t4, $t4, 1 # vai para o proximo codigo da mesa
	#add $t0, $t0, $t5 #indo para o registro de pedidos
	
        add $t7, $t6, $0 #tamanho restante total para percorrer array, esse valor vai ser reduzido de 
        clear_register_de_pedidos:
            addi $t0, $t0, 1 #indo para o proximo byte
            sb $0, 0($t0) #salvando zero no byte indicado
            sub $t7, $t7, 1
            bgtu $t7, $0, clear_register_de_pedidos #Caso $t7 ainda n�o seja igual a zero, significa que ainda temos bytes para zerar 
	#Quando $t0 sair desse loop, ele vai estar apontando para a primeira posi��o da proxima mesa (seu respectivo codigo)
        j loop_mesas_format

    # End of mesa_format
    end_mesa_format:
    #print_string(sucesso_mesa_format)
    #macro_print_string_on_MMIO(sucesso_mesa_format)
jr $ra #end_mesa_format

#$a0 - codigo da mesa
#$a1 - telefone responsavel
#$a2 - nome responsavel
# ===== Funcao para iniciar uma mesa =====
mesa_iniciar:
addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_ocupacao_mesa #recebendo $a0 como entrada (numero da mesa) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v1, 1, mesa_ocupada_error
	beq $v0, 1, fim_mesa_iniciar
	
	la $t9, mesas #$t9 comeca no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
	lbu $t4, tamanho_mesa # obtem o tamanho de uma mesa
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu $t1,$t4 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t9, $t9, $t5 #move $t0 para o local da mesa
	
	li $t6, 1 #prepara para deixar a mesa como ocupada
	sh $t6, 2($t9) #deixa a mesa como ocupada
	
	lbu $t6, tamanho_ate_o_nome_responsavel #distancia ate o nome responsavel
	add $t9, $t9, $t6 # soma o inicio com a distancia
	
	add $a3, $0, $t9  #Carregando o endere�o destino da c�pia de string para $a3
	#a2 j� possui o valor da string que queremos copiar para $a3
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da c�pia
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	#sh $a2, 0($t0) #salva nome do responsavel na memoria
	
	sub $t9, $t9, $t6 #volta pro comeco da mesa
	lbu $t6, tamanho_ate_o_telefone_responsavel #distancia ate o telefone responsavel
	add $t9, $t9, $t6 # soma o inicio com a distancia
	add $a3, $0, $t9  #Carregando o endere�o destino da c�pia de string para $a3
	move $a2, $a1
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal strcpy #recebendo $a2 como string que queremos copiar e $a3 como o destino da c�pia
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	#sh $a1, 0($t0) #salva o telefone do responsavel
	print_string(sucesso_mesa_iniciar)
	macro_print_string_on_MMIO(sucesso_mesa_iniciar)
	j fim_mesa_iniciar
	mesa_ocupada_error:
	 print_string(falha_mesa_ocupada)
	 macro_print_string_on_MMIO(falha_mesa_ocupada)
fim_mesa_iniciar:
jr $ra

#$a0 - numero das mesa
#$a1 - codigo do produto
mesa_ad_item:
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_ocupacao_mesa #recebendo $a0 como entrada (numero da mesa) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v1, 0, mesa_desocupada_error
	beq $v0, 1, fim_mesa_ad_item
	

	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_codigo_cardapio_valido #recebendo $a1 como entrada codigo produto;
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v0, 1, fim_mesa_ad_item
	
	la $t0, mesas #$t0 comeca no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
	lbu $t4, tamanho_mesa # obtem o tamanho de uma mesa
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu $t1,$t4 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t0, $t0, $t5 #move $t0 para o local da mesa
	lbu $t6, tamanho_ate_o_registro_pedidos #distancia ate o registro de pedidos
	lbu $t8, tamanho_registro_pedidos #tamanho maximo registro de pedidos
	add $t0, $t0, $t6 # soma o inicio com a distancia
	add $t8, $t8, $t0 #local final do registro pedidos (e inico do valor total)
	
	
	search_space:
	lhu $t7, ($t0) #le se existe um codigo de produto
	beq $t7, $0, load_value_not_exist #se valor for zero, nao tem pedido
	beq $t7, $a1 set_existing_value # true se o pedido ja exisitir, adiciona mais um para o pedido existente
	bge $t0, $t8, fim_mesas #verificar se ja se passou 20 vagas
	addi $t0, $t0, 4 #vai para a proxima casa de registro
	j search_space
	j fim_mesas
	
	load_value_not_exist:
	    sh $a1, 0($t0) #Salva o codigo do produto
	    li $t7, 1
	    sh $t7, 2($t0) #Cria a quantidade com 1
	    j adiciona_preco
	set_existing_value:
	    lhu $t7, 2($t0) #obtem a quantidade atual de produtos existentes
	    addi $t7, $t7, 1 #adiciona mais um na quantidade
	    sh $t7, 2($t0) #adiciona nova quantidade
	    j adiciona_preco
	adiciona_preco:
	    add $a0, $0, $a1 #colocando codigo do produto em $a0
	    addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	    sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	    jal retornar_infos_item_cardapio #Params ($a0 -> id do item que o usuario gostaria de ter o nome e o preco)
	    lw $ra, 0($sp)	#Recupenrando o $ra antigo
	    addi $sp, $sp, 4 #voltando a pilha pro lugar original
	    add $t9, $0, $v0 #salvando valor do produto em #t9
	    lhu $t2, ($t8) #obtem valor total ja existente
	    add $t9, $t9, $t2 # adiciona valor do produto ao preco existente
	    sh $t9, 0($t8) #Adiciona valor total (ler valor do produto no t9)
	    print_string(sucesso_mesa_ad_item)
	    macro_print_string_on_MMIO(sucesso_mesa_ad_item)
	    jr $ra
	    j fim_mesas
	 
	 mesa_desocupada_error:
	 print_string(falha_mesa_desocupada)
	 macro_print_string_on_MMIO(falha_mesa_desocupada)
	 
	 jr $ra	
	    fim_mesa_ad_item:
	    jr $ra   
	    
j fim_mesas #Return (None)

mesa_rm_item:
lhu $t0, limite_mesas

#fazer validacoes 
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_ocupacao_mesa #recebendo $a0 como entrada (numero da mesa) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v1, 0, mesa_desocupada_error
	beq $v0, 1, fim_mesa_rm_item
	

	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_codigo_cardapio_valido #recebendo $a1 como entrada codigo produto;
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v0, 1, fim_mesa_rm_item
#inicio

	la $t0, mesas #$t0 comeca no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
	lbu $t4, tamanho_mesa # obtem o tamanho de uma mesa
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu $t1,$t4 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t0, $t0, $t5 #move $t0 para o local da mesa
	lbu $t6, tamanho_ate_o_registro_pedidos #distancia ate o registro de pedidos
	lbu $t8, tamanho_registro_pedidos #tamanho maximo registro de pedidos
	add $t0, $t0, $t6 # soma o inicio com a distancia
	add $t8, $t8, $t0 #local final do registro pedidos (e inico do valor total)
	
	search_space_remove:
	lhu $t1, ($t0) #le se existe um codigo de produto
	beq $t1, $0, remove_item_nao_existe #se valor for zero, nao tem pedido
	beq $t1, $a1 remover_um_item # true se o pedido ja exisitir, remove um para o pedido existente
	bge $t0, $t8, fim_mesas #verificar se ja se passou 20 vagas
	addi $t0, $t0, 4 #vai para a proxima casa de registro
	j search_space_remove
	remover_um_item:
	    lhu $t9, 2($t0) #obtem a quantidade atual de produtos existentes
	    subi $t9, $t9, 1 #remove mais um na quantidade
	    sh $t9, 2($t0) #adiciona nova quantidade
	    #validar se a nova quantidade for 0
	    add $a0, $0, $a1 #colocando codigo do produto em $a0
	    addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	    sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	    move $k0, $t0
	    jal retornar_infos_item_cardapio #Params ($a0 -> id do item que o usuario gostaria de ter o nome e o preco)
	    lw $ra, 0($sp)	#Recupenrando o $ra antigo
	    addi $sp, $sp, 4 #voltando a pilha pro lugar original
	    add $t1, $0, $v0 #salvando valor do produto em #t9
	    lhu $t2, ($t8) #obtem valor total ja existente
	    sub $t1, $t2, $t1 # remove o valor do produto ao preco existente
	    sh $t1, 0($t8) #substitui valor total (ler valor do produto no t9)
	    beq $t9, $0, item_zerado
	    j finaliza_mesa_rm_item_sucesso
	item_zerado:
	#remove o item da memoria
	sh $0, 0($k0)#esvazia o item da memoria
	
	j finaliza_mesa_rm_item_sucesso
	finaliza_mesa_rm_item_sucesso:
	print_string(sucesso_mesa_rm_item)
	macro_print_string_on_MMIO(sucesso_mesa_rm_item)
	remove_item_nao_existe:
	fim_mesa_rm_item:
	jr $ra
	
#a0 = codigo da mesa
#a1 = string com valor a ser pago em centavos no padrao XXXXXX
mesa_pagar:
#validacoes
addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_ocupacao_mesa #recebendo $a0 como entrada (numero da mesa) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v1, 0, mesa_desocupada_error
	beq $v0, 1, fim_mesa_rm_item
#inicio
	la $t0, mesas #$t0 comeca no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
	lbu $t4, tamanho_mesa # obtem o tamanho de uma mesa
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu $t1,$t4 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t0, $t0, $t5 #move $t0 para o local da mesa
	lbu $t6, tamanho_ate_o_registro_pedidos #distancia ate o registro de pedidos
	lbu $t8, tamanho_registro_pedidos #tamanho maximo registro de pedidos
	add $t0, $t0, $t6 # soma o inicio com a distancia
	add $t8, $t8, $t0 #local final do registro pedidos (e inico do valor total)
	add $t1, $0, $a1 #salvando valor do pagamento em $t1
	lhu $t2, ($t8) #obtem valor total ja existente
	sub $t1, $t2, $t1 # remove o valor do produto ao preco existente
	sh $t1, 0($t8) #substitui valor total (ler valor do produto no t9)
	print_string(sucesso_pagamento_mesa)
	macro_print_string_on_MMIO(sucesso_pagamento_mesa)
j fim_mesa_pagar
fim_mesa_pagar:
jr $ra

#$a0 = codigo mesa
mesa_fechar:
#validacoes
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_ocupacao_mesa #recebendo $a0 como entrada (numero da mesa) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v1, 0, mesa_desocupada_error
	beq $v0, 1, fim_mesa_rm_item
	#inicio
	la $t0, mesas #$t0 comeca no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
	lbu $t4, tamanho_mesa # obtem o tamanho de uma mesa
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu $t1,$t4 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t0, $t0, $t5 #move $t0 para o local da mesa
	move $k0, $t0
	lbu $t6, tamanho_ate_o_registro_pedidos #distancia ate o registro de pedidos
	lbu $t8, tamanho_registro_pedidos #tamanho maximo registro de pedidos
	add $t0, $t0, $t6 # soma o inicio com a distancia
	add $t8, $t8, $t0 #local final do registro pedidos (e inico do valor total)
	lhu $t9, ($t8) #obtem valor total ja existente
	ble $t9, $0, sucesso_mesa_pagar
	print_string(falha_mesa_fechar)
	macro_print_string_on_MMIO(falha_mesa_fechar)
	print_int($t9) #FORMATAR PARA TER O PADRAO DE XXXXX,XX
	j fim_mesa_fechar
	sucesso_mesa_pagar:
	#APAGAR RESTANTE DAS INFORMACOES
	lhu $t1, limite_mesas #$t1 define a quantidade m�xima de mesas (15)
    	lbu $t2, tamanho_codigo_mesa 
    	lhu $t3, tamanho_mesa
    	li $t4, 1 #codigo de cada mesa, come�a em 1 e vai at� $t1 (limite_mesas)
    	lbu $t5, tamanho_status_mesa
    	sub $t6, $t3, $t2 #tamanho total da mesa - tamanho do codigo da mesa
    	sub $t6, $t6, $t5 # tamanho total da mesa - tamanho do codigo da mesa - tamanho da flag da mesa = quantidade de bytes restantes, onde todos esses bytes vao ser zerados
    
    	#Interando em cada mesa
        add $t0, $k0, $t2 #indo para a flag da mesa
        sh $0, 0($t0) #coloca mesa desocupada
        addi $t0, $t0, 1
        sb $0, 0($t0) #Zerando os dois bytes da flag
        add $t7, $t6, $0 #tamanho restante total para percorrer array, esse valor vai ser reduzido de 
        clear_fechar:
            addi $t0, $t0, 1 #indo para o proximo byte
            sb $0, 0($t0) #salvando zero no byte indicado
            sub $t7, $t7, 1
            bgtu $t7, $0, clear_fechar #LIMPANDO UM POUCO DEMAIS!!!
	print_string(sucesso_mesa_fechar)
	macro_print_string_on_MMIO(sucesso_mesa_fechar)

j fim_mesa_fechar
fim_mesa_fechar:
jr $ra

#a0 - Codigo da mesa
mesa_parcial:
#validacoes
	addi $sp, $sp, -4 #Reservando espa�o na mem�ria para salvar o $ra
	sw $ra, 0($sp) #Salvando o valor de $ra para poder voltar a funcao
	jal checar_ocupacao_mesa #recebendo $a0 como entrada (numero da mesa) para ver se ele j� existe.
	lw $ra, 0($sp)	#Recupenrando o $ra antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
	
	beq $v1, 0, mesa_desocupada_error
	beq $v0, 1, fim_mesa_rm_item
	#inicio
	print_string(mesa_parcial_string)
	macro_print_string_on_MMIO(mesa_parcial_string)
	print_int($a0)
	macro_print_number_on_MMIO($a0)
	print_string(line_breaker)
	macro_print_string_on_MMIO(line_breaker)
	
	la $t0, mesas #$t0 comeca no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
	lbu $t4, tamanho_mesa # obtem o tamanho de uma mesa
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu $t1,$t4 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t0, $t0, $t5 #move $t0 para o local da mesa
	
	lbu $t6, tamanho_ate_o_registro_pedidos #distancia ate o registro de pedidos
	lbu $t8, tamanho_registro_pedidos #tamanho maximo registro de pedidos
	add $t0, $t0, $t6 # soma o inicio com a distancia
	add $t8, $t8, $t0 #local final do registro pedidos (e inico do valor total)
	
	
	
	search_space_parcial:
	lhu $t7, ($t0) #le se existe um codigo de produto
	beq $t7, $0, imprimir_valores #se valor for zero, nao tem pedido
	print_string(codigo_produto)
	macro_print_string_on_MMIO(codigo_produto)
	print_int($t7) #imprimir codigo do produto ($t7)
	macro_print_number_on_MMIO($t7)
	print_string(line_breaker)
	macro_print_string_on_MMIO(line_breaker)
	lhu $t7, 2($t0) #obtem a quantidade atual de produtos existentes
	print_string(quantidade_produto)
	macro_print_string_on_MMIO(quantidade_produto)
	print_int($t7) #imprimir quantidade ($t7)
	macro_print_number_on_MMIO($t7)
	print_string(line_breaker)
	macro_print_string_on_MMIO(line_breaker)
	
	bge $t0, $t8, imprimir_valores #verificar se ja se passou 20 vagas
	addi $t0, $t0, 4 #vai para a proxima casa de registro
	j search_space_parcial
	
	
	
	
	
	imprimir_valores:
	#imprime valor a pagar e valor pago
	lhu $t9, ($t8) #obtem valor total ja existente
	print_string(valor_a_ser_pago)
	macro_print_string_on_MMIO(valor_a_ser_pago)
	print_int($t9)
	macro_print_number_on_MMIO($t9)
	print_string(line_breaker)
	macro_print_string_on_MMIO(line_breaker)
	 #Reais e centavos ----
		 #addi $t7, $0, 100 #dividir na base 100
		 #div $t9, $t7
		 #mflo $t7
		 #mfhi $t6
		 #print_int($t9)
		#macro_print_string_on_MMIO(cardapio_rs)
		# macro_print_number_on_MMIO($t7)
		 #macro_print_string_on_MMIO(cardapio_virgula)
		 #macro_print_number_on_MMIO($t6)
		 #print_string(line_breaker)
		 #macro_print_string_on_MMIO(line_breaker)
		# add $t3, $a1, $0
		# add $t4, $a2, $0
	#print_int($t9) #imprimir valor a pagar ($t9)
	#macro_print_number_on_MMIO($t9)
	#print_string(line_breaker)
	#macro_print_string_on_MMIO(line_breaker)
	j fim_mesa_parcial
	fim_mesa_parcial:
	jr $ra


j fim_mesas #Return (None)
#============ Funcoes Extras ===============

#===== Checar se uma mesa de id $a0 estah ocupada ou nao =====
checar_ocupacao_mesa: #Params ($a0 -> id da mesa que serah checada | int)
    	la $t0, mesas #$t0 marca o inicio do gerenciador de mesas
    	lhu $t1, limite_mesas #$t1 define a quantidade m�xima de mesas (15)
   	addi $t2, $0, 1 #$t2 vai percorrer de 1 at� o limite
    	lhu $t3, tamanho_mesa
    	lbu $t5, tamanho_codigo_mesa

	#Checando se o id da mesa inserido estah no intervalo entre 1-limite_mesas
	bge $a0, 1, checar_limite_superior_mesa # Se $a0 >= 1
	j falha_mesa_codigo_alcance  # Pula para o final da fun��o

	checar_limite_superior_mesa:
	ble $a0, $t1, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele est� dentro do limite 1-20
	j falha_mesa_codigo_alcance  # Pula para o final da fun��o
	
	dentro_do_limite:
	
	subi $t1, $a0, 1 #remove 1 do numero da mesa para obter o indice
	multu  $t1,$t3 	#Calculando o offset para se chegar no proximo espaco de memoria livre reservado para uma mesa (160 bytes).
	mflo $t5 	#$t5 recebe o resultado da multiplicacao anterior
	add $t0, $t0, $t5 #move $t0 para o local da mesa
	
	addi $v0, $0, 0 #0 = mesa existente
	lbu $t4, 2($t0) #$t4 recebe se a mesa esta disponivel ou indisponivel
	add $v1, $0, $t4 #v1 possui 1 se a mesa esta ocupada, e zero se a mesa esta desocupada
	j fim_checar_ocupacao_mesa
	falha_mesa_codigo_alcance:
		print_string(falha_codigo_mesa_invalido)
		macro_print_string_on_MMIO(falha_codigo_mesa_invalido)
		addi $v0, $0, 1 #1 = out of range
		addi $v1, $0, -1 #-1 = inexistente
 
	fim_checar_ocupacao_mesa:
jr $ra # Return ($v0 -> 0 se a mesa estiver existir, 1 se o id nao estiver no range (1-limite_mesas), int,
			  #$v1 -> retorna 0 se a mesa estiver disponivel, caso esteja indisponivel, $v1 retorna 1, retorna -1 caso a mesa nao exista | address int )


checar_codigo_cardapio_valido: #Params ($a1 > id do codigo do produto que sera checado | int)
#Checando para ver se o codigo produto digitado esta entre 1-20
	lhu $t0, limite_cardapio
	bge $a1, 1, checar_limite_cardapio_superior # Se $a0 >= 1
	j falha_cardapio_codigo_alcance  # Pula para o final da funcao

	checar_limite_cardapio_superior:
	ble $a1, $t0, dentro_do_limite_cardapio    # Se $a0 <= limite_cardapio(20) significa que ele esta dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da funcao
	falha_cardapio_codigo_alcance:
		print_string(falha_codigo_cardapio_invalido)
		macro_print_string_on_MMIO(falha_codigo_cardapio_invalido)
		addi $v0, $0, 1 #1 = out of range
		j fim_checar_codigo_cardapio_valido
	dentro_do_limite_cardapio:
	addi $v0, $0, 0 #0 = ok
	fim_checar_codigo_cardapio_valido:
	jr $ra #return ($v0 = 0 se estiver ok, =1 se nao estiver ok) 
fim_mesas:




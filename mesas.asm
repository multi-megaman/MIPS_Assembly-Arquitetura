.data
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
mesas_white_space: .space 6
string_de_teste:.asciiz"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
mesas: .space 2400 #Alocando o espa�o do gerenciados das XX mesas
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
tamanho_ate_o_registro_pedidos: .byte 76 # tamanho para o registro de pedidos
tamanho_registro_pedidos: .byte 80 # tamanho para o registro de pedidos
.text

.globl  mesa_iniciar, mesa_format, mesa_ad_item

j fim_mesas

# ===== Funcao para iniciar uma mesa =====
mesa_iniciar: #Params

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
    sub $t6, $t6, $t5 # tamanho total da mesa - tamanho do codigo da mesa - tamanho da flag da mesa = quantidade de bytes restantes, onde todos esses bytes vao ser zerados
    
    #Interando em cada mesa
    loop_mesas_format:
        bgt $t4, $t1,end_mesa_format # se codigo da mesa > $t1 (limite_mesa), sai do loop
        sh $t4, 0($t0) #coloca codigo da mesa
        add $t0, $t0, $t2 #indo para a flag da mesa
        sh $0, 0($t0) #coloca mesa desocupada
        addi $t4, $t4, 1 # vai para o proximo codigo da mesa
        add $t0, $t0, $t5 #indo para o registro de pedidos

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
jr $ra #end_mesa_format

#$a0 - numero das mesa
#$a1 - codigo do produto
mesa_ad_item:

#Checando para ver se o codigo da mesadigitado esta entre 1-15

	lhu $t0, limite_mesas
	bge $a0, 1, checar_limite_superior_mesa # Se $a0 >= 1
	j falha_mesa_codigo_alcance  # Pula para o final da funcao

	checar_limite_superior_mesa:
	ble $a0, $t0, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele est� dentro do limite 1-20
	j falha_mesa_codigo_alcance  # Pula para o final da funcao
	
	dentro_do_limite_mesa:
	
	#Checando para ver se o codigo produto digitado esta entre 1-20
	lhu $t0, limite_cardapio
	bge $a1, 1, checar_limite_superior # Se $a0 >= 1
	j falha_cardapio_codigo_alcance  # Pula para o final da funcao

	checar_limite_superior:
	ble $a1, $t0, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele esta dentro do limite 1-20
	j falha_cardapio_codigo_alcance  # Pula para o final da funcao
	
	dentro_do_limite:
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
	    jal retornar_infos_item_cardapio #Params ($a0 -> id do item que o usuario gostaria de ter o nome e o preco)
	    add $t9, $0, $v0 #salvando valor do produto em #t9
	    lhu $t2, ($t8) #obtem valor total ja existente
	    add $t9, $t9, $t2 # adiciona valor do produto ao preco existente
	    sh $t9, 0($t8) #Adiciona valor total (ler valor do produto no t9)
	    j fim_mesas
	    
	    falha_mesa_codigo_alcance:
	    falha_cardapio_codigo_alcance:
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
	
	falha_mesa_codigo_alcance:
		print_string(falha_codigo_mesa_invalido)
		addi $v0, $0, 2 #2 = out of range
		addi $v1, $0, -1 #-1 = inexistente
 
	fim_checar_ocupacao_mesa:
jr $ra # Return ($v0 -> 1 se a mesa estiver ocupada, 0 se estiver desocupada, 2 se o id nao estiver no range (1-limite_mesas), int,
			  #$v1 -> retorna a posicao do primeiro byte da mesa se ela estiver disponivel, caso esteja indisponivel, $v1 retorna -1 | address int )

fim_mesas:




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
	
#Calculo do espaï¿½o do gerenciamento das 15 mesas
	# 2 (codigo) + 2 (status) + 61 (responsavel) + 11 (telefone) + 80 (registro de pedidos) + 4 (valor total) = 160 bytes para cada mesa
	# Total: 160 * 15 = 2.400 bytes
mesas_white_space: .space 6
string_de_teste:.asciiz"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
mesas: .space 2400 #Alocando o espaï¿½o do gerenciados das XX mesas
mesas_white_space_2: .space 4

limite_mesas: .half 15 		                            #int -> indica qual o limite total de mesas
ponteiro_mesas: .half 0 		                            #int -> Sempre vai estar apontando para a proxima posicao livre do gerenciador de mesa. Quando chega em limite_cardapio, indica que a proxima posiï¿½ï¿½o livre estah fora do espaï¿½o reservado.
tamanho_mesas: .half 2460 				   #Indica o tamanho total do gerenciador de mesa
tamanho_mesa: .half 160				   #Indica o tamanho total de uma unica mesa
tamanho_codigo_mesa: .byte 2			  #Indica o tamanho do codigo de uma mesa
tamanho_status_mesa: .byte 2			  #Indica o tamanho do status de uma mesa
tamanho_nome_responsavel_mesa: .half 61    #Indica o tamanho do nome do responsavel de uma mesa
tamanho_telefone_mesa: .half 11			  #Indica o tamanho do telefone de uma mesa
tamanho_codigo_item_mesa: .byte 2		 #Indica o tamanho do codigo de um unico item do cardapio
tamanho_quantidade_item_mesa: .byte 2       #Indica o tamanho da quantidade de um unico item do cardapio
tamanho_item_geral_mesa: .byte 4		#Indica o tamanho total de um ï¿½nico item do cardapio
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

.text

.globl  mesa_iniciar, mesa_format

j fim_mesas

# ===== Funcao para iniciar uma mesa =====
mesa_iniciar: #Params

jr $ra #Return ($v0 -> 0 para sucesso, 1 para falha | bool)

# ==== Funcao para formatar as mesas =====
mesa_format: #Params (None)
    la $t0, mesas #$t0 começa no inicio do gerenciador de mesas e vai percorrendo de mesa em mesa
    lhu $t1, limite_mesas #$t1 define a quantidade máxima de mesas (15)
    lbu $t2, tamanho_codigo_mesa 
    lhu $t3, tamanho_mesa
    li $t4, 1 #codigo de cada mesa, começa em 1 e vai até $t1 (limite_mesas)
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
            bgtu $t7, $0, clear_register_de_pedidos #Caso $t7 ainda não seja igual a zero, significa que ainda temos bytes para zerar 
	#Quando $t0 sair desse loop, ele vai estar apontando para a primeira posição da proxima mesa (seu respectivo codigo)
        j loop_mesas_format

    # End of mesa_format
    end_mesa_format:
jr $ra #Return (None)

#============ Funcoes Extras ===============

#===== Checar se uma mesa de id $a0 estah ocupada ou nao =====
checar_ocupacao_mesa: #Params ($a0 -> id da mesa que serah checada | int)
    	la $t0, mesas #$t0 marca o inicio do gerenciador de mesas
    	lhu $t1, limite_mesas #$t1 define a quantidade máxima de mesas (15)
   	addi $t2, $0, 1 #$t2 vai percorrer de 1 até o limite
    	lhu $t3, tamanho_mesa
    	lbu $t5, tamanho_codigo_mesa

	#Checando se o id da mesa inserido estah no intervalo entre 1-limite_mesas
	bge $a0, 1, checar_limite_superior_mesa # Se $a0 >= 1
	j falha_mesa_codigo_alcance  # Pula para o final da função

	checar_limite_superior_mesa:
	ble $a0, $t1, dentro_do_limite    # Se $a0 <= limite_cardapio(20) significa que ele está dentro do limite 1-20
	j falha_mesa_codigo_alcance  # Pula para o final da função
	
	dentro_do_limite:
	
	falha_mesa_codigo_alcance:
		print_string(falha_codigo_mesa_invalido)
		addi $v0, $0, 2 #2 = out of range
		addi $v1, $0, -1 #-1 = inexistente
 
	fim_checar_ocupacao_mesa:
jr $ra # Return ($v0 -> 1 se a mesa estiver ocupada, 0 se estiver desocupada, 2 se o id nao estiver no range (1-limite_mesas), int,
			  #$v1 -> retorna a posicao do primeiro byte da mesa se ela estiver disponivel, caso esteja indisponivel, $v1 retorna -1 | address int )

fim_mesas:




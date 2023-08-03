.data
#Calculando o espaco de memoria necessario para a mesa
	#Calculo para cada mesa individual:
	# Codigo da mesa -> 1-15	      = 4 bits (2^4 = 16 valores)             arredondando para bytes =  2 bytes      unsigned
	#Status da mesa -> 0-1 		      = 1 bit (ou eh 0 ou eh 1)                  arredondando para bytes =  2 bytes      unsigned
	#Nome do responsavel -> 1-60    = 65 bytes = 480 bits		     arredondando para bytes  =   65 bytes   unsigned
	#telefone de contato -> 11	     = 11 bytes   = 88 bits                       arredondando para bytes =   11 bytes     unsigned
	
		#Cada item pedido pela mesa
		#codigo do item -> 1-20          = 5   bits(2^5 = 32 valores)         arredondando para words = 2 bytes    unsigned
		#quantidade do item -> 0-20  = 5   bits(2^5 = 32 valores)        arredondando para words = 2 bytes    unsigned
	
	#Cada item pedido pela mesa x 20 = 80 bytes				     arredondando pra bytes = 80 bytes
	#Valor atual a ser pago (0-99.999*20) = 21 bits			              arredondando pra bytes = 4 bytes signed
	
#Calculo do espa�o do gerenciamento das 15 mesas
	# 2 (codigo) + 2 (status) + 65 (responsavel) + 11 (telefone) + 80 (registro de pedidos) + 4 (valor total) = 164 bytes para cada mesa
	# Total: 164 * 15 = 2.460 bytes
mesas_white_space: .space 6
mesas: .space 2460 #Alocando o espa�o do gerenciados das XX mesas
mesas_white_space_2: .space 4
string_de_teste:.asciiz"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
limite_mesas: .half 15 		                            #int -> indica qual o limite total de mesas
ponteiro_mesas: .half 0 		                            #int -> Sempre vai estar apontando para a proxima posicao livre do gerenciador de mesa. Quando chega em limite_cardapio, indica que a proxima posi��o livre estah fora do espa�o reservado.
tamanho_mesas: .half 2460 				   #Indica o tamanho total do gerenciador de mesa
tamanho_mesa: .half 164				   #Indica o tamanho total de uma unica mesa
tamanho_codigo_mesa: .byte 2			  #Indica o tamanho do codigo de uma mesa
tamanho_status_mesa: .byte 2			  #Indica o tamanho do status de uma mesa
tamanho_nome_responsavel_mesa: .half 65    #Indica o tamanho do nome do responsavel de uma mesa
tamanho_telefone_mesa: .half 11			  #Indica o tamanho do telefone de uma mesa
tamanho_codigo_item_mesa: .byte 2		 #Indica o tamanho do codigo de um unico item do cardapio
tamanho_quantidade_item_mesa: .byte 2       #Indica o tamanho da quantidade de um unico item do cardapio
tamanho_item_geral_mesa: .byte 4		#Indica o tamanho total de um �nico item do cardapio
tamanho_registro_de_pedidos: .byte 20       #Indica quantos pedidos difedentes podem ser feitos
tamanho_valor_a_ser_pago: .half 32		#Indica o tamanho do valor a ser pago

.text

#.globl 

# Define the mesa_format function
mesa_format:
    # Load the pointer to the mesa array into $t0
    la $t0, mesas

    # Load the pointer to the limite_mesas variable into $t1
    lhu $t1, limite_mesas

    li $t4, 1 #codigo da mesa, comeca com 1
    # Loop through all the mesas
    loop_mesas_format:
        # Check if we have reached the limit of mesas
        bgt $t4, $t1, end_format # se codigo da mesa > 15, sai do loop

        sb $t4, -2($t0) #coloca codigo da mesa
        sb $0, 0($t0) #coloca mesa desocupada
        addi $t4, $t4, 1 # vai para o proximo codigo da mesa
        
        li $t6, 0 #Inicia contador de pulo de memoria, inciando com 0
         
        li $t7, 160 #tamanho restante total para percorrer array
        clear_register_de_pedidos:
            add $t5, $t0, $t6 #adiciona endereco de memoria + contador
            addi $t6, $t6, 2 #adiciona 2 no contador
            sh $t8, 2($t5) #coloca half 0  
            sub $t7, $t7, 2 #remove 2 do tamanho restante do array
            bnez $t7, clear_register_de_pedidos #sai do loop quando t7 chega a 0

        # Move to the next mesa
        addi $t0, $t0, 164

        # Repeat for the next mesa
        j loop_mesas_format

    # End of mesa_format
    end_format:
    j fim_mesas

j fim_mesas


fim_mesas:




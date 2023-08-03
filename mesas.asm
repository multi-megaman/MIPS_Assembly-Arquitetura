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
	
#Calculo do espaço do gerenciamento das 15 mesas
	# 2 (codigo) + 2 (status) + 65 (responsavel) + 11 (telefone) + 80 (registro de pedidos) + 4 (valor total) = 164 bytes para cada mesa
	# Total: 164 * 15 = 2.460 bytes
mesas_white_space: .space 6
mesas: .space 2460 #Alocando o espaço do gerenciados das XX mesas
mesas_white_space_2: .space 4
string_de_teste:.asciiz"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
limite_mesas: .half 15   		                            #int -> indica qual o limite total de mesas
ponteiro_mesas: .half 0 		                            #int -> Sempre vai estar apontando para a proxima posicao livre do gerenciador de mesa. Quando chega em limite_cardapio, indica que a proxima posição livre estah fora do espaço reservado.
tamanho_mesas: .half 2460 				   #Indica o tamanho total do gerenciador de mesa
tamanho_mesa: .half 164				   #Indica o tamanho total de uma unica mesa
tamanho_codigo_mesa: .byte 2			  #Indica o tamanho do codigo de uma mesa
tamanho_status_mesa: .byte 2			  #Indica o tamanho do status de uma mesa
tamanho_nome_responsavel_mesa: .half 65    #Indica o tamanho do nome do responsavel de uma mesa
tamanho_telefone_mesa: .half 11			  #Indica o tamanho do telefone de uma mesa
tamanho_codigo_item_mesa: .byte 2		 #Indica o tamanho do codigo de um unico item do cardapio
tamanho_quantidade_item_mesa: .byte 2       #Indica o tamanho da quantidade de um unico item do cardapio
tamanho_item_geral_mesa: .byte 4		#Indica o tamanho total de um único item do cardapio
tamanho_registro_de_pedidos: .byte 20       #Indica quantos pedidos difedentes podem ser feitos
tamanho_valor_a_ser_pago: .half 32		#Indica o tamanho do valor a ser pago
.text

#.globl 

j fim_mesas


fim_mesas:




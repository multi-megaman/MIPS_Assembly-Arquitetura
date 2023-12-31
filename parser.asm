.data

#Grupo: Ru-Rural
#integrantes: 
#Pedro Henrique
#Everton da Silva
#Ricardo Pompilio


#Macros

string_funcionou_1: .asciiz "deu perfeitamente certo "
parser_comando_invalido: "COMANDO INVALIDO!!!\n"
parser_string_nota_number: .asciiz "NOT A NUMBER"
parse_string_string_invalida: .asciiz "String invalida\n"
.macro print_string(%string)
	addi $sp, $sp, -4
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	
	addi $v0, $0, 4
	la $a0, %string
	syscall
	
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	addi $sp, $sp, 4 #voltando a pilha pro lugar original
.end_macro

.macro macro_print_string_on_MMIO(%string)
	addi $sp, $sp, -8
	sw $a0, 0($sp) #Salvando o valor de $a0
	sw $ra, 4($sp) #Salvando o valor de $ra para poder voltar a funcao
	la $a0, %string
	jal print_string_on_MMIO
	lw $a0, 0($sp)	#Recuperando o $a0 antigo
	lw $ra, 4($sp) #Recuperando o $a0 antigo
	addi $sp, $sp, 8 #voltando a pilha pro lugar original
.end_macro


.text
.globl parse_string, converter_string_para_int


#======================Parse da String=================
j super_hiper_end2

parse_string: #fun��o que separa a string informada em paramentros ($a0, $a1, $a2, $a3) e pula diretamente para a fun��o informada na String
	addi $sp, $sp, -4
	sw $ra, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	
	#codigo dos char: (- = 45) ( _ = 95) (a = 97) (c = 99) (e = 101) (f = 102) (g = 103) (i = 105) (l = 108) (m = 109) (0 = 111) {p = 112} (r = 114) (s = 115)
	add $t0, $0, $a0 #movendo o endere�o base da String para $t0
	add $t9, $0, $a0 #salvando o endere�o inicial da String em $t9 para ser usado depois da separa��o da String
	add $t1, $0, $0 #registrador auxiliar que indica qual argumento foi encontrado
	parse_string_loop:
		lb $t2, 0($t0) #carregando o byte atual
		beq $t2, 0, parse_string_fim #verifica se a String chegou ao final
		beq $t2, 45, parse_string_achou #verifica se chegou ao primeiro argumento esta comparando o valor carregado com "-"
		addi $t0, $t0, 1 #somando 1 ao endere�o base
		j parse_string_loop #reinicia o loop
	
	parse_string_achou:
		beq $t1, 0, parse_string_achou0 #vai para a area onde sera salvo o primeiro argumento
		beq $t1, 1, parse_string_achou1 #vai para a area onde sera salvo o segundo argumento
		beq $t1, 2, parse_string_achou2 #vai para a area onde sera salvo o terceiro argumento
		
		parse_string_achou0:
			addi $t0, $t0, 1 #adiciona 1 ao endereco atual para pegar o primeiro elemento da String e n�o o simbolo "-"
			add $a0, $t0, $0 #salvando o endereco base do primeiro arguemento
			addi $t1, $t1, 1 #somando 1 ao contador de argumento
			j parse_string_loop #volta pro loop
			
		parse_string_achou1:
			sb $0, 0($t0) #colocando \0 no final do argumento anterior
			addi $t0, $t0, 1 #adiciona 1 ao endereco atual para pegar o primeiro elemento da String e nao o simbolo "-"
			add $a1, $t0, $0 #salvando o segundo argumento
			addi $t1, $t1, 1 #somando 1 ao contador de argumento
			j parse_string_loop #volta pro loop
			
		parse_string_achou2:
			sb $0, 0($t0) #colocando \0 no final do argumento anterior
			addi $t0, $t0, 1 #adiciona 1 ao endereco atual para pegar o primeiro elemento da String e nao o simbolo "-"
			add $a2, $t0, $0 #salvando o terceiro argumento
			j parse_string_loop #volta pro loop

	parse_string_fim: #codigo que vai direcionar para onde o programa vai :)
		add $t0, $0, $t9 #movendo o endereco base da String de $t9 para #t0
		add $t9, $t1, $0 #movendo o contador de argumento para $t9 para poder verificar se os argumentos foram informados corretamente
		lb $t1, 0($t0) #carregando o primeiro char da String
		beq $t1, 99, parse_string_cardapio #compara o char com "c" para saber se e um comando de cardapio
		beq $t1, 109, parse_string_mesa #compara o char com "m" para saber se e um comando de mesa
		j parse_string_arquivo #como so sobrou comandos de arquivo pula diretamente
		j parse_string_invalida #imprime o aviso de string invalida
		
		parse_string_cardapio:
			addi $t0, $t0, 9 #somando 9 ao endere�o pois vai direto para o char depois do "_"
			lb $t1, 0($t0)  #carregando o primeiro char depois do "_"
			beq $t1, 97, parse_string_cardapio_ad #comparando com "a"
			beq $t1, 114, parse_string_cardapio_rm #comparando com "r"
			beq $t1, 108, parse_string_cardapio_list #comparando com "l"
			beq $t1, 102, parse_string_cardapio_format #comparando com f
			j parse_string_invalida #imprime o aviso de string invalida
			
			
			parse_string_cardapio_ad: #100%
				blt $t9, 2, parse_string_invalida #verifica se foram informados menos do que 3 argumentos
				add $a3, $a0, $0 #movendo o valor de $a0 para $a3 pois e o argumento usado na funcao abaixo
				jal converter_string_para_int #funcao que converter uma String em um valor inteiro
				add $a0, $v0, $0 #movendo o resultado para $a0
				add $a3, $a1, $0 #colocando $a1 como paramentro para a funcao abaixo
				jal converter_string_para_int #converte string para int
				add $a1, $v0, $0 #movendo o resultado de volta pra $a1
				jal cardapio_ad #pula para a funcao de adicionar item no cardapio
				j super_hiper_end #finaliza a fun��o do parser
				 
			parse_string_cardapio_rm: #100%
				blt $t9, 1, parse_string_invalida
				add $a3, $a0, $0 #uso da funcao string para int
				jal converter_string_para_int
				add $a0, $v0, $0 #salvando o retorno da funcao
				jal cardapio_rm #pula para a funcao de remover item do cardapio
				j super_hiper_end #finaliza a funcao do parser
				
			parse_string_cardapio_list: #100%
				jal cardapio_list #pula para a funcao que lista todos os itens do cardapio
				j super_hiper_end #finaliza a funcao do parser
				
			parse_string_cardapio_format: #100%
				jal cardapio_format #pula para a funcao que apaga todos os itens do cardapio
				j super_hiper_end #finaliza a funcao do parser
		
		parse_string_mesa:
			addi $t0, $t0, 5 #pula para o quinto caracter da string sendo o primeiro caracter referente ao comando da mesa
			lb $t1, 0($t0) #carrega o byte
			beq $t1, 105, parse_string_mesa_iniciar #compara com "i"
			beq $t1, 97, parse_string_mesa_ad_item #compara com "a"
			beq $t1, 114, parse_string_mesa_rm_item #compara com "r"
			beq $t1, 102, parse_string_mesa_f #compara com "f"
			beq $t1, 112, parse_string_mesa_p #compara com "p"
			j parse_string_invalida #imprime o aviso de string invalida
			
			
			
			
			parse_string_mesa_iniciar: #100%
				blt $t9, 1, parse_string_invalida #imprime o aviso de string invalida
				add $a3, $a0, $0 #uso da funcao string para int
				jal converter_string_para_int #funcao que converte uma string para um numero inteiro
				add $a0, $v0, $0 #salva o retorno da funcao
				#j zona_testes_parse_string
				jal mesa_iniciar #pula para a funcao que inicia uma mesa
				j super_hiper_end #finaliza da funcao do parser
				
			parse_string_mesa_ad_item: #100%
				blt $t9, 2, parse_string_invalida #imprime o aviso de string invalida
				add $a3, $a0, $0 #uso da funcao string para int
				jal converter_string_para_int #funcao que converte de string para int
				add $a0, $v0, $0 #salvando o retorno da funcao
				add $a3, $a1, $0 #uso da funcao string para int
				jal converter_string_para_int #funcao que converter uma string para um valor inteiro
				add $a1, $v0, $0 #salvando o retorno da funcao
				jal mesa_ad_item #pula para a funcao que adiciona um item a mesa
				j super_hiper_end #finaliza a funcao parser
				
			parse_string_mesa_rm_item: #100%
				blt $t9, 2, parse_string_invalida #imprimime o aviso de string invalida
				add $a3, $a0, $0 #uso da funcao string para int
				jal converter_string_para_int #funcao que converte de string para int
				add $a0, $v0, $0 #salvand o retorno da funcao
				add $a3, $a1, $0 #uso da funcao string para int
				jal converter_string_para_int #fucao que converte de string para int
				add $a1, $v0, $0  #salvando o retorno da funcao
				jal mesa_rm_item #pula para a funcao que remove um item da mesa
				j super_hiper_end #finaliza a funcao do parser
				
			parse_string_mesa_f:
				addi $t0, $t0, 1 #adicionando 1 ao endere�o para pegar o proximo char pois � o char mais proximo que diferencia as duas funcoes iniciadas com "f"
				lb $t1, 0($t0) #carregando o char
				beq $t1, 111, parse_string_mesa_format #comparando com "o"
				beq $t1, 101, parse_string_mesa_fechar #comparando com "e"
				j parse_string_invalida #imprime o aviso de string invalida
				
				parse_string_mesa_format: #100% 
					jal mesa_format #pula para a funcao espeficicada
					j super_hiper_end #finaliza o parser
					
				parse_string_mesa_fechar: #100%
					blt $t9, 1, parse_string_invalida #imprime o aviso de string invalida
					add $a3, $a0, $0 #uso da funcao string para int
					jal converter_string_para_int #converte uma string para um valor inteiro
					add $a0, $v0, $0 #salvando o retorno da funcao
					#j zona_testes_parse_string
					jal mesa_fechar #pula para a funcao informada
					j super_hiper_end
				
			parse_string_mesa_p:
				addi $t0, $t0, 2 #adiciona dois ao endereco pois e o char mais proximo que diferencia as duas funcoes iniciadas com "p"
				lb $t1, 0($t0) #carrega o char
				beq $t1, 114, parse_string_mesa_parcial #compara com "r"
				beq $t1, 103, parse_string_mesa_pagar #compara com "g"
				j parse_string_invalida #imprime o aviso de string invalida
				 
				parse_string_mesa_parcial: #100%
					blt $t9, 1, parse_string_invalida #imprime o aviso de string invalida
					add $a3, $a0, $0 #uso da funcao string para int
					jal converter_string_para_int #funcao que converte string para int
					add $a0, $v0, $0  #salvando o retorno da funcao
					jal mesa_parcial #pula para a funcao especificada
					j super_hiper_end #finaliza o parser
					
				parse_string_mesa_pagar: #100%
					blt $t9, 2, parse_string_invalida
					add $a3, $a0, $0 #uso da funcao string para int
					jal converter_string_para_int #funcao que converte de string para int
					add $a0, $v0, $0 #salva o retorno da funcao
					add $a3, $a1, $0 #uso da funcao string para int
					jal converter_string_para_int #funcao que converte de string para int
					add $a1, $v0, $0 #salva o retorno da funcao
					jal mesa_pagar #pula para a funcao especificada
					j super_hiper_end #finaliza o parser
				
				
		parse_string_arquivo:
			beq $t1, 115, parse_string_arquivo_salvar #compara com "s"
			beq $t1, 114, parse_string_arquivo_recarregar #compara com "r"
			beq $t1, 102, parse_string_arquivo_formatar #compara com "f"
			j parse_string_invalida #imprime o aviso de string invalida 
			
			
			parse_string_arquivo_salvar: #100%
				jal salvar #pula para a funcao de salvar no arquivo
				j super_hiper_end #finaliza o parser
			parse_string_arquivo_recarregar: #100%
				jal recarregar #pula para a fun��o de tirar o conteudo do arquivo e colocar na memoria
				j super_hiper_end #finaliza o parser
			parse_string_arquivo_formatar: #100%
				jal formatar #pular para a fun��o que apaga todos os dados do arquivo
				j super_hiper_end #finaliza o parser
				

	parse_string_invalida: #parte do codigo que vai servir para quando a string digitada n�o atender aos padr�es
		print_string(parser_comando_invalido) #imprime a string "COMANDO INVALIDO!!!"
		 macro_print_string_on_MMIO(parser_comando_invalido) #imprime a string na interface do MMIO
		j super_hiper_end #finaliza o parser
		
	parse_string_not_a_number:
		print_string(parser_string_nota_number) #imprime a string "NOT A NUMBER"
		 macro_print_string_on_MMIO(parser_string_nota_number) #imprime a string na interface do MMIO
		j super_hiper_end #finaliza o parser
		

	
converter_string_para_int: #funcaoo que vai converter uma string para um inteiro recebe a String em $a3 e retorna o resultado em $v0
	add $t0, $0, $a3 #movendo o valor em $a3 que sao usado como parametro nessa funcaoo para $t0
	lb $t1, 0($t0) #carregando o primeiro byte do numero
	subi $t1, $t1, 48 #subtraindo 48 pois o 0 e representado pelo numero 48 e os seguintes numeros na ordem
	blt $t1, 0, parse_string_not_a_number #imprime o aviso informando que o paramentro informado nao e um numero
	bgt $t1, 9, parse_string_not_a_number #imprime o aviso informando que o paramentro informado nao e um numero
	
		converter_string_para_int_loop:
			addi $t0, $t0, 1 #adiciona 1 ao endere�o para pegar o proximo byte
			lb $t2, 0($t0) #carrega o byte
			beq $t2, $0, converter_string_para_int_fim #verifica se o byte � 0 - � impossivel confundir com o char "0" pois ele � representado pelo numero 48
			subi $t2, $t2, 48 #subtrai 48 para converter de char para int
			blt $t2, 0, parse_string_not_a_number #imprime o aviso informando que o paramentro informado nao e um numero
			bgt $t2, 9, parse_string_not_a_number #imprime o aviso informando que o paramentro informado nao e um numero
			mul $t1, $t1, 10 #multiplica o numero ja armazenado por 10 pois sera adicionado mais uma casa a esquerda desse numero apos isso
			add $t1, $t1, $t2 #adiciona o numero que estava na string ao numero salvo at� o momento
			j converter_string_para_int_loop #reinicia o loop
			
			
				
			converter_string_para_int_fim:
			add $v0, $t1, $0 #coloca o numero encontrado em $v0 para retornar a fun��o
			jr $ra	 #retorna a fun�o para onde foi chamada
			
super_hiper_end:
lw $ra, 0($sp)	#Recuperando o $ra antigo
addi $sp, $sp, 4 #voltando a pilha pro lugar original
jr $ra
#cardapio 100% pronto
#mesa ad
#mesa format
#mesa rm
super_hiper_end2:

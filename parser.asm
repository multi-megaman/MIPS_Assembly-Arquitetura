.data

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
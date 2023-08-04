.data
#testes
string_usuario: .space 59
input_string_usuario: .asciiz"Digite um coment�rio para o item por favor: "
#white_space: .space 24 #S� para o card�pio come�ar em um lugar mais bonitinho no visualizador do MARS
string_teste_parse: .asciiz "cardapio_ad-15-00490-coca cola" #vai servir para testar o parse da string

.macro print_string(%string)
	addi $sp, $sp, -4
	sw $a0, 0($sp) #Salvando o valor de $a0 para poder voltar a funcao
	
	addi $v0, $0, 4
	la $a0, (%string)
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

.text
main:
#j parse_string_testes #vai pular diretamente para a area do parse da String
la $a0, string_teste_parse
jal parse_string

zona_testes_parse_string:

li $v0, 1
syscall

add $a0, $a1, $0
syscall

#j super_end

#!!!!!!!!!!!!!! INICIO DA ZONA DE TESTES !!!!!!!!!!!!!!!!!!!!!!!!!
#---�rea de testes para pegar a descri��o do usu�rio, essa parte ser� substituida com o CLI posterior, mas por agora para se adicionar um item no card�pio, � preciso ler essa string
addi $v0, $0, 4 #Printar String
la $a0, input_string_usuario
syscall

la $a0, string_usuario #carrega o endere�o de string em $a0 para ser utilizado na leitura (saber onde vai come�ar a armazenar os caracteres?)
addi $a1, $0, 60 #carregando o maximo de caracteres para leitura
addi $v0,$0, 8 # Servi�o 8 l� uma string
syscall
add $a2, $0, $a0 #armazena o valor lido em $a2 (string do usuario) 
#OBS: A descri��o dos itens por enquanto � a mesma para todos eles, j� que estamos pegando apenas uma �nica string para isso

#---Valores de teste referentes ao id do item ($a0) e ao pre�o dele ($a1)
addi $a0, $0, 1
addi $a1, $0, 1000
jal cardapio_ad
jal cardapio_ad #Erro: Item j� cadastrado
jal cardapio_ad #Erro: Item j� cadastrado

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
jal cardapio_ad # Erro: C�digo inv�lido

addi $a0, $0, 0
addi $a1, $0, 78214
jal cardapio_ad # Erro: C�digo inv�lido

#Remover item
addi $a0, $0, 21
jal cardapio_rm #Erro: c�digo inv�lido

#Descomentar para testar a remo��o de um item n�o cadastrado. Precisa comentar o c�digo de adi�ao do item de id 20
#addi $a0, $0, 20
#jal cardapio_rm #Erro: c�digo n�o cadastrado

addi $a0, $0, 20 #testando a remo��o do ultimo item
jal cardapio_rm #Sucesso

addi $a0, $0, 19 #testando a remo��o do ultimo item (mas n�o no limite)
jal cardapio_rm #Sucesso

addi $a0, $0, 4 #testando a remo��o de um item aleatorio
jal cardapio_rm #Sucesso

addi $a0, $0, 1 #testando a remo��o do primeiro item
jal cardapio_rm #Sucesso

#Adicionando um item ap�s uma dele��o
addi $a0, $0, 19 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 12394
jal cardapio_ad #Sucesso

addi $a0, $0, 20 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 11111
jal cardapio_ad #Sucesso

addi $a0, $0, 4 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 74848
jal cardapio_ad #Sucesso

addi $a0, $0, 4 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 73748
jal cardapio_ad #Erro: Item j� cadastrado

addi $a0, $0, 1 #testando a adi��o de um item ap�s uma remo��o
addi $a1, $0, 68356
jal cardapio_ad #Sucesso

#Checando a existencia de um c�digo no card�pio
addi $a0, $0, 3
addi $a1, $0, 1600
jal checar_existencia_de_codigo #Retorna 1 (c�digo encontrado)

#Checando o print do card�pio
jal cardapio_list #Sucesso

#Chegando as informa��es de um item do card�pio
addi $a0, $0, 3
jal retornar_infos_item_cardapio	
add $t0, $v0, $0
print_int($t0)
print_string($v1)


#Teste da formata��o do card�pio
#jal cardapio_format




#Fun��es============================================================================================================================================================
super_end:
	
	

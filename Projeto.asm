.data
#testes
string_usuario: .space 59
input_string_usuario: .asciiz"Digite um comentario para o item por favor: "
white_space: .space 3 #Soh para o cardapio comecar em um lugar mais bonitinho no visualizador do MARS
telefone_teste:.asciiz"08198765432"
nome_teste:.asciiz"Jose Silva"
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
#inicando uma mesa
    	# $a0 - C�digo da mesa (01 a 15)
    	# $a1 - Telefone do respons�vel (string com 11 caracteres)
    	# $a2 - Nome do respons�vel (string com at� 60 caracteres)
    	#addi $a0, $0, 8
    	#la $a1, telefone_teste_usuario
	#la $a2, nome_teste_usuario
#jal mesa_iniciar


#!!!!!!!!!!!!!! INICIO DA ZONA DE TESTES !!!!!!!!!!!!!!!!!!!!!!!!!
#---area de testes para pegar a descricao do usuario, essa parte serah substituida com o CLI posterior, mas por agora para se adicionar um item no cardapio, � preciso ler essa string
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

jal mesa_format

#$a0 - codigo da mesa
#$a1 - telefone responsavel
#$a2 - nome responsavel
addi $a0, $0, 2
la $a1, telefone_teste
la $a2, nome_teste
jal mesa_iniciar

addi $a0, $0, 2
addi $a1, $0, 3
jal mesa_ad_item

addi $a0, $0, 2
addi $a1, $0, 1500
jal mesa_pagar

addi $a0, $0, 2
jal mesa_parcial

addi $a0, $0, 2
jal mesa_fechar

addi $a0, $0, 2
addi $a1, $0, 3
jal mesa_rm_item

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
jal cardapio_rm #Erro: codigo inv�lido

#Descomentar para testar a remo��o de um item n�o cadastrado. Precisa comentar o codigo de adi�ao do item de id 20
#addi $a0, $0, 20
#jal cardapio_rm #Erro: codigo n�o cadastrado

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

#Checando a existencia de um codigo no cardapio
addi $a0, $0, 3
addi $a1, $0, 1600
jal checar_existencia_de_codigo #Retorna 1 (codigo encontrado)

#Checando o print do cardapio
jal cardapio_list #Sucesso

#Chegando as informacoes de um item do cardapio
addi $a0, $0, 3
jal retornar_infos_item_cardapio	 #Retorna o valor e a descricao do item
add $t0, $v0, $0
print_int($t0)  #printa o valor
print_string($v1) #printa a descricao


#Teste da formata��o do cardapio
#jal cardapio_format

#Teste das mesas

#Fun��es============================================================================================================================================================

	
	

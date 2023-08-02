.data
#testes
string_usuario: .space 59
input_string_usuario: .asciiz"Digite um comentário para o item por favor: "
white_space: .space 24 #Só para o cardápio começar em um lugar mais bonitinho no visualizador do MARS

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
main:
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

#Teste da formatação do cardápio
#jal cardapio_format




#Funções============================================================================================================================================================

	
	

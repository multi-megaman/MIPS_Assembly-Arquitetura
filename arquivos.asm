.data

#Grupo: Ru-Rural
#integrantes: 
#Pedro Henrique
#Everton da Silva
#Ricardo Pompilio


local_arquivo: .asciiz "D:/GitHub/MIPS_Assembly-Arquitetura/arquivo.txt"
local_testes: .space 1


.text

.globl salvar, recarregar, formatar

j end
salvar:
	#abrir o arquivo
	li $v0, 13 #codigo para a abertura do arquivo
	la $a0, local_arquivo #passando o local do arquivo
	li $a1, 1 #1 representa abertura de arquivo no modo escrita
	syscall
	
	add $t9, $v0, $0 #salvando o descritor do arquivo
	
	#escrevendo no arquivo
	li $v0, 15 #codigo para escrever no arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	la $a1, inicio_arquivo_byte1 #carregando o endereco da string que sera salva
	li $a2, 3722 #limite de caracteres que serao salvos (um numero maior do que deveria pode armazenar coisas indesejadas
	syscall
	
	#fechar o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	jr $ra #voltando para a fun��o que chamou



recarregar:
	#abrir o arquivo no modo leitura
	li $v0, 13 #solicita a abertura
	la $a0, local_arquivo #endereco do arquivo em $a0
	li $a1, 0 #0: leitura; 1: escrita;
	syscall

	add $t9, $v0, $0 #salvando uma copia do descritor

	add $a0, $t9, $0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0
	la $a1, inicio_arquivo_byte1 #buffer que armazena o conteudo
	li $a2, 1 #tamanho do buffer
	syscall
	la $t0, inicio_arquivo_byte1
	lb $t1, 0($t0)
	beq $t1, 48, arquivo_voltar_main #comparando com o char "0"
	
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	
	
	li $v0, 13 #solicita a abertura
	la $a0, local_arquivo #endereco do arquivo em $a0
	li $a1, 0 #0: leitura; 1: escrita;
	syscall

	add $t9, $v0, $0 #salvando uma copia do descritor
	
	add $a0, $t9, $0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0
	la $a1, inicio_arquivo_byte1 #buffer que armazena o conteudo
	li $a2, 3722 #tamanho do buffer
	syscall
	
	arquivo_voltar_main:
	#fechando o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	jr $ra #voltando para o lugar que essa funcao foi chamada
	
	
formatar:
	#abrir o arquivo
	li $v0, 13 #codigo para a abertura do arquivo
	la $a0, local_arquivo #passando o local do arquivo
	li $a1, 1 #1 representa abertura de arquivo no modo escrita
	syscall
	
	add $t9, $v0, $0 #salvando o descritor do arquivo
	
	#escrevendo no arquivo
	li $v0, 15 #codigo para escrever no arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	la $a1, inicio_arquivo_byte0 #carregando o endereco da string que sera salva
	li $a2, 1 #limite de caracteres que serao salvos (um numero maior do que deveria pode armazenar coisas indesejadas
	syscall
	
	#fechar o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	jr $ra #voltando para a funcao que chamou


end:

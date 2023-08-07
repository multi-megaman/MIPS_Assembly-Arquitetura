.data
local_arquivo: .asciiz "D:/GitHub/MIPS_Assembly-Arquitetura/arquivo.txt"
local_testes: .space 40


.text

j recarregar
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
	la $a1, ponteiro_cardapio #carregando o endere�o da string que ser� salva
	li $a2, 3720 #limite de caracteres que ser�o salvos (um numero maior do que deveria pode armazenar coisas indesejadas
	syscall
	
	#fechar o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	#jr $ra #voltando para a fun��o que chamou



recarregar:
	#abrir o arquivo no modo leitura
	li $v0, 13 #solicita a abertura
	la $a0, local_arquivo #endereco do arquivo em $a0
	li $a1, 0 #0: leitura; 1: escrita;
	syscall

	add $t9, $v0, $0 #salvando uma copia do descritor

	add $a0, $t9, $0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0
	la $a1, local_testes #buffer que armazena o conteudo
	li $a2, 1 #tamanho do buffer
	syscall
	la $t0, local_testes
	lb $t1, 0($t0)
	beq $t1, 48, arquivo_voltar_main #comparando com o char "0"
	
	
	add $a0, $t9, $0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0
	la $a1, local_testes #buffer que armazena o conteudo
	li $a2, 100 #tamanho do buffer
	syscall
	
	arquivo_voltar_main:
	#fechando o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	#jr $ra #voltando para o lugar que essa fun��o foi chamada
	j end
	
	
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
	#la $a1, input_string_usuario #carregando o endere�o da string que ser� salva
	li $a2, 0 #limite de caracteres que ser�o salvos (um numero maior do que deveria pode armazenar coisas indesejadas
	syscall
	
	#fechar o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	#jr $ra #voltando para a fun��o que chamou


end:
li $v0, 10
syscall

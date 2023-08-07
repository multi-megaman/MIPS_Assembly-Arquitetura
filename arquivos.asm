.data
local_arquivo: .asciiz "D:/GitHub/MIPS_Assembly-Arquitetura/arquivo.txt"
string_teste: .asciiz "string de testes 123\nso pra testar a quebra de linha"
formatar_arquivo: .asciiz ""
conteudo_arquivo: .space 1024

.text

j fim_arquivo
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
	#la $a1, input_string_usuario #carregando o endere�o da string que ser� salva
	li $a2, 1200 #limite de caracteres que ser�o salvos (um numero maior do que deveria pode armazenar coisas indesejadas
	syscall
	
	#fechar o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	#jr $ra #voltando para a fun��o que chamou



recarregar:
	#abrir o arquivo no modo leitura
	li $v0, 13 #solicita a abertura
	la $a0, local_arquivo #endere�o do arquivo em $a0
	li $a1, 0 #0: leitura; 1: escrita;
	syscall

	add $t9, $v0, $0 #salvando uma copia do descritor

	add $a0, $t9, $0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0
	la $a1, conteudo_arquivo #buffer que armazena o conteudo
	li $a2, 1024 #tamanho do buffer
	syscall

	#fechando o arquivo
	li $v0, 16 #codigo para fechar o arquivo
	add $a0, $t9, $0 #colocando o descritor do arquivo em $a0
	syscall
	#jr $ra #voltando para o lugar que essa fun��o foi chamada
	
	
	
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


fim_arquivo:
#li $v0, 10
#syscall

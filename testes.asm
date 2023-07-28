.data
string: .ascii"zzzzzz"
teste1: .space 20
teste2: .space 20
string2: .ascii"zzzzzz" 
.text
main:
addi $v0, $0, 8 #read string
la $a0, teste2
addi $a1, $0, 20
syscall


#$a0 -> local inicial da memoria que vai ser deslocado
#$a1 -> local final da mem�ria que vai ser deslocado
#$a2 -> endere�o de mem�ria onde o deslocamento vai come�ar
la $a0, teste2
addi $a1, $a0, 20 # endere�o de mem�ria inicial + o seu tamanho
la $a2, teste1 
jal shift_mem_left

addi $v0, $0, 10 
syscall #end program

#===== Deslocar uma quantidade x ($a1 - $a0) de bits para a esquerda ($a2)
shift_mem_left: #Params ($a0 -> local inicial do conjunto de bytes que vai ser copiado | memory address,
					 # $a1 -> local final do conjunto de bytes que vai ser copiado   | memory address,
					 # $a2 -> local inicial para onde o conjunto vai ser copiado       | memory address)
#Registradores temporarios utilizados:
#$t0 -> vai percorrer o conjunto de bits e vai copia-los
#$t1 -> vai percorrer, junto com o $t0 e vai servir para $t0 copiar o byte para $t1
#$t2 -> byte que estar� na posi��o $t0
add  $t0, $0, $a0 # come�a no valor inicial de copia
add $t1, $0, $a2 # come�a nop valor inicial do destino
lb $t2, 0($t0)
loop_shift_mem_left:
	beq $t0, $a1, fim_shift_mem_left
	sb $t2, 0($t1) #copiando o byte para o destino a esquerda
	sb $0, 0($t0) #apagando o conteudo anterior, j� que ele j� foi copiado
	addi $t0, $t0, 1 #indo para o pr�ximo endere�o de mem�ria
	addi $t1, $t1, 1 #indo para o pr�ximo endere�o de mem�ria
	lb $t2, 0($t0) #carregando o proximo byte
	j loop_shift_mem_left
fim_shift_mem_left:
jr $ra		   #Return (None)
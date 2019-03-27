	.data
buffer: 	.space 4
offset: 	.space 4
size: 		.space 4
width: 		.space 4
height:		.space 4
start:		.space 4
x1:		.space 4
y1:		.space 4
x2:		.space 4
y2:		.space 4
x3:		.space 4
y3:		.space 4

msgTitle:	.asciiz "Rysowanie krzywej Beziera\n"
msgGetData:	.asciiz "Podaj wspolrzedne punktow kontrolnych: "
msgError:	.asciiz "Blad zwiazany z plikiem\n"
msgx1:		.asciiz "\n x1 = "
msgy1:		.asciiz " y1 = "
msgx2:		.asciiz " x2 = "
msgy2:		.asciiz " y2 = "
msgx3:		.asciiz " x3 = "
msgy3:		.asciiz " y3 = "
msgFinished:	.asciiz "\n Wynik zapisany do pliku wyjsciowego\n"
fileIn:		.asciiz "in2.bmp"
fileOut:	.asciiz "out.bmp"

	.text
	.globl main
	
main:
	#wysiwetl tytul
	la $a0, msgTitle
	li $v0, 4
	syscall
	
readFile:
	#otworz plik wejsciowy
	la $a0, fileIn
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	
	#destryptor pliku do $t0
	move $t0, $v0	
	# jesli t0<0 to wyswietl error
	bltz $t0, fileError		
	
	#odczytaj bajty 'BM' z naglowka
	move $a0, $t0
	la $a1, buffer
	li $a2, 2
	li $v0, 14  
	syscall	
	
	#odczytaj rozmiar
	move $a0, $t0
	la $a1, size
	li $a2, 4
	li $v0, 14
	syscall
	
	#zapisujemy rozmiar w s0
	lw $s0, size
	
	#zaalokuj pamiec na dane
	move $a0, $s0
	li $v0, 9
	syscall
	
	#adres zaalokowanej pamieci do $s1
	move $s1, $v0
	sw $s1, start
	
	#odczytaj kolejne 4 bajty
	move $a0, $t0
	la $a1, buffer
	li $a2, 4
	li $v0, 14
	syscall
	
	#odczytaj offset
	move $a0, $t0
	la $a1, offset
	li $a2, 4
	li $v0, 14
	syscall
	
	#odczytaj kolejne 4 bajty
	move $a0, $t0
	la $a1, buffer
	li $a2, 4
	li $v0, 14
	syscall
	
	#odczytaj szerokosc obrazka
	move $a0, $t0
	la $a1, width
	li $a2, 4
	li $v0, 14
	syscall
	lw $s2, width

	#odczytaj wysokosc obrazka
	move $a0, $t0
	la $a1, height
	li $a2, 4
	li $v0, 14
	syscall
	lw $s3, height
	
	#zamknij plik
	move $a0, $t0
	li $v0, 16
	syscall
	
readBytes:
	# wczytuje tablice pikseli do pod adres zaalokowanej pamieci w $s1
	la $a0, fileIn
	la $a1, 0
	la $a2, 0
	li $v0, 13
	syscall

	#destryptor pliku do $t0
	move $t0, $v0	
	# jesli t0<0 to wyswietl error
	bltz $t0, fileError		
	
	move $a0, $t0
	la $a1, ($s1)		#poczatek zaalokowanej pamieci
	la $a2, ($s0)		#maksymalna liczba znakow do wczytania, tyle co rozmiar
	li $v0, 14
	syscall
	
	lw $s0, size
	#zamkniecie pliku
	move $a0, $t0
	li $v0, 16
	syscall
	
readPoints: #odczytaj parametry od uzytkownika
	la $a0, msgGetData
	li $v0, 4
	syscall
	
	#x1
	la $a0, msgx1
	li $v0, 4
	syscall
	
	li $v0, 5 
	syscall
	sll $v0, $v0, 16
	sw $v0, x1
	
	#y1
	la $a0, msgy1
	li $v0, 4
	syscall
	
	li $v0, 5 
	syscall
	sll $v0, $v0, 16
	sw $v0, y1
	
	#x2
	la $a0, msgx2
	li $v0, 4
	syscall
	
	li $v0, 5 
	syscall
	sll $v0, $v0, 16
	sw $v0, x2
	
	#y2
	la $a0, msgy2
	li $v0, 4
	syscall

	li $v0, 5 
	syscall
	sll $v0, $v0, 16
	sw $v0, y2
	
	#x3
	la $a0, msgx3
	li $v0, 4
	syscall
	
	li $v0, 5 
	syscall
	sll $v0, $v0, 16
	sw $v0, x3
	
	#y3
	la $a0, msgy3
	li $v0, 4
	syscall
	
	li $v0, 5 
	syscall
	sll $v0, $v0, 16
	sw $v0, y3


setValues:
	# s4 - parametr t
	li $s4, 0
	# 16 bitow na czesc ulamkowa
	#s5 - 1, do wstawienia do wzoru
	li $s5, 1
	sll $s5, $s5, 16
	#t9 - 2, do wstawienia do wzoru
	li $t9, 2
	sll $t9, $t9, 16
	
	li $t1, 4 #padding
	mul $t0, $s2, 3 
	divu $t0, $t1
	mfhi $s7 
	
loop:
	#s4 - t
	#s5 - 1
	#t9 - 2
	
x:
	lw $t2, x1
	lw $t3, x2
	lw $t4, x3

	#(1-t)
	subu $t0, $s5, $s4
	#(1-t)^2
	mul $t6, $t0, $t0
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t0, $t5, $t6
	#(1-t)^2 * x1
	mul $t6, $t0, $t2
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t0, $t5, $t6

	#(1-t)
	subu $t1, $s5, $s4
	#(1-t)*t
	mul $t6, $t1, $s4
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t1, $t5, $t6 
	#(1-t)*t*2
	mul $t6, $t1, $t9
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t1, $t5, $t6 
	#(1-t)*t*2*x2
	mul $t6, $t1, $t3
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t1, $t5, $t6 
	
	add $t0, $t0, $t1
	
	#t^2
	move $t7, $s4
	mul $t6, $t7, $s4
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t7, $t5, $t6 
	#t^2 * x3
	mul $t6, $t7, $t4
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t7, $t5, $t6 
	
	add $t0, $t0, $t7	 	
	
	sra $t0, $t0, 16
	move $a3, $t0
	
y:
	lw $t2, y1
	lw $t3, y2
	lw $t4, y3
	
	#(1-t)
	subu $t0, $s5, $s4
	#(1-t)^2
	mul $t6, $t0, $t0
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t0, $t5, $t6
	#(1-t)^2 * y1
	mul $t6, $t0, $t2
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t0, $t5, $t6

	#(1-t)
	subu $t1, $s5, $s4
	#(1-t)*t
	mul $t6, $t1, $s4
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t1, $t5, $t6 
	#(1-t)*t*2
	mul $t6, $t1, $t9
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t1, $t5, $t6 
	#(1-t)*t*2*y2
	mul $t6, $t1, $t3
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t1, $t5, $t6 
	
	add $t0, $t0, $t1
	
	#t^2
	move $t7, $s4
	mul $t6, $t7, $s4
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t7, $t5, $t6 
	#t^2 * y3
	mul $t6, $t7, $t4
	mfhi $t5
	sll $t5, $t5, 16
	srl $t6, $t6, 16
	or $t7, $t5, $t6 
	
	add $t0, $t0, $t7	 	
	
	sra $t0, $t0, 16
	
	addi $s4, $s4, 0x00000008 


draw:
	#t0 - wspolrzedna y
	#a3 - wspolrzedna x
	#s0 - offset
	#s1 - start
	#s2 - width
	#s3 - height
	#s7 - padding
	
	lw $s1, start
	lw $s0, offset
	addu $s1, $s1, $s0
	#wyznacz wartosc y pixela
	mul $t2, $s2, 3 
	mul $t2, $t0, $t2
	addu $s1, $s1, $t2
	#wyznacz wartosc x pixela
	mul $t1, $a3, 3 
	addu $s1, $s1, $t1
	#padding
	mul $t2, $t0, $s7
	addu $s1, $s1, $t2
	
	#pokoloruj pixel
	li $t2, 0x22
	sb $t2, ($s1)
	addi $s1, $s1, 1
	li $t2, 0x8b
	sb $t2, ($s1)
	addi $s1, $s1, 1
	li $t2, 0x22
	sb $t2, ($s1)
	addi $s1, $s1, 1
	#skocz, jesli t != 1
	bne $s4, 0x00010000, loop
	
saveFile:
	la $a0, fileOut
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	
	#destryptor pliku do $t0
	move $t0, $v0	
	# jesli t0<0 to wyswietl error
	bltz $t0, fileError		

	lw $s0, size
	lw $s1, start
	
	move $a0, $t0
	la $a1, ($s1)
	la $a2, ($s0)
	li $v0, 15 
	syscall
	
	move $a0, $t0
	li $v0, 16 
	syscall 
	
exit:
	#wysiwetl informacje o zakonczeniu pracy
	la $a0, msgFinished
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall


fileError:
	#wyswietl informacje o bledzie
	la $a0, msgError
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	

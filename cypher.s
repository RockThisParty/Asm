global _start
section .data
	file db "./test.txt", 0
	len equ 1024
	key equ 5
section .bss
	buffer: resb 1024
section .text
_start:
	mov eax, 5
	mov ebx, file
	mov ecx, 0
	int 80h

	mov eax, 3
	mov ebx, eax
	mov ecx, buffer
	mov edx, len
	int 80h

	mov eax, 4
	mov ebx, 1
	mov ecx, buffer
	mov edx, len
	int 80h
	
	call encrypt

	mov eax, 5
	int 80h

	mov eax, 1
	mov ebx, 0
	int 80h

encrypt:
._start:
	push eax
	push ebx
	push ecx
	push edx
._cicl:
	mov eax,5
	mov ebx,file
	mov ecx, 0
	int 80h

	mov eax, 3
	mov ebx, eax
	mov ecx,buffer
	mov bl,byte[buffer+key]
	mov edx, len
	cmp 
	int 80h
	
pop edx
pop ecx
pop ebx
pop eax
ret
	

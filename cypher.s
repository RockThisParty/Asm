global _start

section .data
	file db "Name: "
	len equ $-file
	char db '*'
	enter: db 10
	delete db 08h, 20h, 08h

section .bss
	termios resb 36
	buf resb 1024
	b_len equ $-buf
	key resb 80
	key_len equ $-key

section .text
_start:
	mov eax, 4
	mov ebx, 1
	mov ecx, file
	mov edx, len
	int 80h
	
	xor eax, eax	
	times 3 inc eax
	xor ebx, ebx
	mov ecx, buf
	mov edx, b_len
	int 80h
	and [buf+eax-1], byte 0

	mov eax, 5
	mov ebx, buf
	xor ecx, ecx
	int 80h

	mov ebx, eax	
	xor eax, eax	
	times 3 inc eax
	mov ecx, buf
	mov edx, b_len
	int 80h
	dec eax

	push ebx

	mov eax, 4
	mov ebx, 1
	mov ecx, enter
	int 80h
	push edx

	mov eax, 54
	xor ebx, ebx
	mov ecx, 5401h
	mov edx, termios
	int 80h

	push dword [termios+12]
	and [termios+12], dword ~10		
	mov eax, 54
	inc ecx
	int 80h

	push esi
	xor esi, esi
	xor edx, edx
	inc edx

_key_in:
	xor eax,eax
	times 3 inc eax
	xor ebx, ebx 
	mov ecx, key
	add ecx, esi
	int 80h

	cmp byte [ecx], 10
	je _key_enter
	cmp byte [ecx], 127
	je _key_delete
	mov eax, 4
	inc ebx
	mov eax, 4
	inc ebx
	mov ecx, char
	int 80h
	
	inc esi
	cmp esi, key_len
	jl _key_in
	jmp _key_end

_key_delete:
	test esi, esi
	jz _key_in
	mov eax, 4
	inc ebx
	mov ecx, delete
	times 2 inc edx
	int 80h
	times 2 dec edx
	dec esi
	jmp _key_in

_key_enter:
	test esi, esi
	jz _key_in
	mov [char], byte 10
	mov eax, 4
	inc ebx
	mov ecx, char
	int 80h

_key_end:
	pop dword [termios+12]
	mov eax, 54
	xor ebx,ebx
	mov ecx, 5402h
	mov edx, termios
	int 80h	

	mov edi, buf
	mov ebx, esi
	mov esi, key
	pop eax

	mov edx, eax
	mov eax, 4
	xor ebx, ebx
	inc ebx
	mov ecx, edi
	int 80h	

	mov eax, 6
	pop ebx
	int 80h

	mov eax, 4
	mov ebx, 1
	mov ecx, enter
	mov edx, 1
	int 80h

	mov eax, 1
	xor ebx, ebx
	int 80h
	

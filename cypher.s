global _start

section .data
	file db "filename: "
	file_len equ $-file
	password db "password: "
	pass_len equ $-password
	char: db '*'
	delete db 0x08, 0x20, 0x08
	;print_count: dw 95
	enter: db 10

section .bss
	termios: resb 36
	buf: resb 4096
	buf_len: equ $-buf
	key: resb 80
	key_len: equ $-key

section .text
_start:
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,file
	mov edx,file_len
	int 0x80	;print("filename: ")

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,buf
	mov edx,buf_len
	int 0x80	;user input from keyboard
	mov [buf+eax-1],byte 0	;replace enter to '\0'

	mov eax,5
	mov ebx,buf
	xor ecx,ecx
	int 0x80	;open file with typed name

	mov ebx,eax
	xor eax,eax
	times 3 inc eax
	mov ecx,buf
	mov edx,buf_len
	int 0x80	;read from file to buffer
	
	dec eax

	push ebx	;descriptor at stack

	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,buf
	int 0x80	;print file content
	
	push edx
	
	mov eax,4
	mov ecx,enter
	xor edx,edx
	inc edx
	int 0x80

	mov eax,4
	mov ecx,password
	mov edx,pass_len
	int 0x80
	
	mov eax,54	;syscall_ioctl
	xor ebx,ebx	;stdin
	mov ecx,0x5401	;TCGETS
	mov edx,termios
	int 0x80
	
	push dword [termios+12]	;save current terminal params

	and [termios+12],dword ~10	;disable canonical and echo flags
	mov eax,54	;syscall_ioctl
	inc ecx	;TCSETS
	int 0x80

	xor esi,esi
	xor edx,edx
	inc edx

key_in:
	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,key
	add ecx,esi
	int 0x80	;read single char from keyboard
	cmp byte [ecx],10	;why test byte [ecx],10 doesn't work?
	je key_enter	;if (enter)
	cmp byte [ecx],127
	je key_delete	;if (backspace)
	mov eax,4
	inc ebx	;ebx=1
	mov ecx, char
	int 0x80
	inc esi
	cmp esi,key_len
	jl key_in
	jmp key_end

key_delete:
	test esi,esi
	jz key_in
	mov eax,4
	inc ebx
	mov ecx,delete
	times 2 inc edx
	int 0x80
	times 2 dec edx
	dec esi
	jmp key_in

key_enter:
	test esi,esi
	jz key_in
	mov [char],byte 10
	mov eax,4
	inc ebx
	mov ecx,char
	int 0x80
key_end:
	pop dword [termios+12]
	mov eax,54	;syscall_ioctl
	xor ebx,ebx	;stdin
	mov ecx,0x5402	;TCSETS
	mov edx,termios
	int 0x80

	mov edi,buf	;text
	mov ebx,esi	;key lenght
	mov esi,key	;key
	pop eax	;text len
	;call encrypt
	;call decrypt

	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,edi
	int 0x80

	mov eax,6
	pop ebx
	int 0x80	;close file

	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,enter
	xor edx,edx
	inc edx
	int 0x80

	xor eax,eax
	inc eax
	xor ebx,ebx
	int 0x80	;prog end

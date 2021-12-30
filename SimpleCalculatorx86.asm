.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
	a	db	20	dup(?)
	b	db	20	dup(?)
	s	db	20	dup(?)
	opt	db	?
	rm	dd	?
	r	dd	?
.data
	oprtr	db	"Select operator:", 0Ah, "1, Addition", 0Ah, "2, Subtraction", 0Ah, "3.Multiply", 0Ah, "4.Division", 0Ah, "-> ", 0
	oprnd	db	"Input 2 operand in 2 lines.", 0Ah, 0
	result	db	"Result: ", 0
	remaind	db	"Remainder: ", 0
	NL		db	0Ah, 0
.code
main PROC
	push	offset oprtr
	call	StdOut
	push	1
	push	offset opt
	call	StdIn

	push	offset oprnd
	call	StdOut
	push	20
	push	offset a		; dont know why :) 
	call	StdIn
	push	20
	push	offset a
	call	StdIn
	push	20
	push	offset b
	call	StdIn

	push	offset b
	call	atoi			
	mov		ebx, eax		; edx = (int) a
	push	offset a
	call	atoi			; eax = (int) a
	@operator:
		sub		opt, 30h
		test	opt, 1
		jz		@SubxDiv
		jnz		@AddxMul
		@AddxMul:
			cmp		opt, 1
			je		@add
			jmp		@mul
			@add:
				add		eax, ebx
				jmp		@finish
			@mul:
				mul		ebx
				jmp		@finish
		@SubxDiv:
			cmp		opt, 2
			je		@sub
			jmp		@div
			@sub:
				sub		eax, ebx
				jmp		@finish
			@div:
				xor		edx, edx
				div		ebx
				jmp		@finish
	@finish:
		mov		r, eax
		mov		rm, edx
		push	offset result
		call	StdOut
		push	r
		push	offset s
		call	itoa
		push	eax
		call	StdOut
		push	offset NL
		call	StdOut
		cmp		opt, 4
		je		@remainder
		jmp		@ret
	@remainder:
		push	offset remaind
		call	StdOut
		push	rm
		push	offset s
		call	itoa
		push	eax
		call	StdOut
	@ret:
		ret
main ENDP

atoi PROC ;parameter: offset buf, output in eax
	push	ebp
	mov		ebp, esp
	push	edx
	push	ebx
	xor		eax, eax
	mov		esi, [ebp + 8h]
	mov		ebx, 10
	@nxtChr:
		xor		edx, edx
		mov		dl, byte ptr [esi]
		xor		dl, 30h
		add		eax, edx
		mul		ebx
		inc		esi
		cmp		byte ptr [esi], 0
		jne		@nxtChr
	div		ebx
	pop		ebx
	pop		edx
	mov		esp, ebp
	pop		ebp
	ret		4
atoi ENDP

itoa PROC	; para1 = val, para2 = string, output in eax
	push	ebp
	mov		ebp, esp
	push	edi
	push	ebx
	push	edx
	push	ecx
	mov		ebx, 0Ah
	mov		eax, [ebp + 0Ch]
	mov		edi, [ebp + 8h]
	@clearstring:
		push	eax
		cld
		mov		ecx, 10
		mov		al, 0
		rep		stosb
		pop eax
	mov		edi, [ebp + 8h]
	add		edi, 0Ah
	@nxtChr:
		dec		edi
		xor		edx, edx
		div		ebx
		or		edx, 30h
		mov		byte ptr [edi], dl
		test	eax, eax			
		jnz		@nxtChr
	mov		eax, edi
	pop		ecx
	pop		edx
	pop		ebx
	pop		edi
	mov		esp, ebp
	pop		ebp
	ret		8h
itoa ENDP
END main
.386
.model flat, stdcall
option casemap: none
.stack 4096

include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data?
	a db 10 dup(?)
	b db 10 dup(?)
	s db 10 dup(?)

.code
main PROC
	push	10
	push	offset a
	call	StdIn
	push	10
	push	offset b
	call	StdIn

	push	offset a
	call	atoi
	mov		edx, eax
	push	offset b
	call	atoi
	add		eax, edx
	push	eax
	push	offset s
	call	itoa
	
	push	eax
	call	StdOut

	ret
main ENDP

atoi PROC ;parameter: offset buf, output in eax
	push	ebp
	mov		ebp, esp
	push	edx
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
	pop		edx
	mov		esp, ebp
	pop		ebp
	ret		4
atoi ENDP

itoa PROC	; para1 = val, para2 = string
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
end main
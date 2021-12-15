.386
.model flat, stdcall
option casemap: none
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
	n	dd	1	dup(?)
	s	db	20	dup(?)
.data
	min	dd	7FFFFFFFh
	max dd	0h
	spc	db	20h
.code
main PROC
	push	20
	push	offset s
	call	StdIn
	push	offset s
	call	atoi
	mov		n, eax		; read n 

	mov		ecx, n
	@readNcmp:
		push	ecx
		push	20
		push	offset s
		call	StdIn
		pop		ecx
		push	offset s
		call	atoi
		@cmp:
			cmp		eax, min
			jl		@less
			cmp		eax, max
			jg		@greater
			loop	@readNcmp
			jecxz	@display
		@less:
			mov		min, eax
			jmp		@cmp
		@greater:
			mov		max, eax
			jmp		@cmp
	@display:
		push	max
		push	offset s
		call	itoa
		push	eax
		call	print
		push	min	
		push	offset s
		call	itoa
		push	eax
		call	print
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

print PROC ; print with 1 space
	push	ebp
	mov		ebp, esp
	push	ecx
	push	[ebp + 8h]
	call	StdOut
	push	offset spc
	call	StdOut
	pop		ecx
	mov		esp, ebp
	pop		ebp
	ret		4h
print ENDP
end main
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
	s	db	21	dup(?)
.code	
main PROC
	push	20
	push	offset a
	call	StdIn
	push	20
	push	offset b
	call	StdIn

	push	offset s
	push	offset b
	push	offset a
	call	sum

	push	offset s
	call	StdOut
	ret
main ENDP

sum PROC 
	push	ebp
	mov		ebp, esp
	push	esi
	push	edi
	push	ecx
	push	edx
	push	eax
	push	ebx

	mov		esi, [ebp + 8h]		; offset para3
	mov		edi, [ebp + 0Ch]	; offset para2
	mov		edx, [ebp + 10h]	; offset para1 (res)
	xor		eax, eax
	xor		ecx, ecx
	mov		bh, 30h
	push	esi
	call	rev
	push	edi
	call	rev					; reverse 2 strings to calculate sum
	@sum2:
		mov		bl, byte ptr [esi + ecx]
		cmp		bl, 0
		jz		@swp
		sub		bl, bh
		mov		ah, bl			; save it
		mov		bl, byte ptr [edi + ecx]
		cmp		bl, 0
		jz		@sum1
		sub		bl, bh
		add		al, bl
		add		al, ah			; sum 2 digits
		mov		bl, 0Ah
		mov		ah, 0			; prepare div
		div		bl				
		add		ah, bh			; take the remainder
		mov		byte ptr [edx + ecx], ah
		inc		ecx
		jmp		@sum2
	@swp:
		xchg	esi, edi
		jmp		@sum1
	@sum1:
		mov		bl, byte ptr [esi + ecx]
		add		al, bl			; the carry
		cmp		al, 0
		jz		@finish
		cmp		al, bh
		jl		@carry
		sub		al, bh
		mov		bl, 0Ah
		mov		ah, 0
		div		bl
		add		ah, bh
		mov		byte ptr [edx + ecx], ah
		inc		ecx
		jmp		@sum1
	@carry:
		add		al, bh
		mov		byte ptr [edx + ecx], al
	@finish:
		push	edx			
		call	rev				; reverse back
	push	esi
	call	rev
	push	edi					; reverse back
	call	rev	

	pop		ebx
	pop		eax
	pop		edx
	pop		ecx
	pop		edi
	pop		esi
	mov		esp, ebp
	pop		ebp
	ret		0Ch
sum ENDP	

rev PROC 
	push	ebp
	mov		ebp, esp
	push	esi
	push	edx
	push	ecx
	mov		esi, [ebp + 8h]	; offset para1
	@loop:
		movzx	edx, byte ptr [esi]
		push	edx
		inc		esi
		test	edx, edx
		jnz		@loop
	pop		edx				; pop '0'
	sub		esi, [ebp + 8h]
	mov		ecx, esi
	sub		ecx, 1
	mov		esi, [ebp + 8h]
	@revL:
		pop		edx
		mov		byte ptr [esi], dl
		inc		esi	
		loop	@revL
	pop		ecx
	pop		edx
	pop		esi
	mov		esp, ebp
	pop		ebp
	ret		4
rev ENDP
end main
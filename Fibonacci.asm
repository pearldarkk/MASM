.386
.model flat, stdcall
option casemap: none
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
	n	db	3	dup(?)
	f0	db	21	dup(?)
	f1	db	21	dup(?)
	f2	db	21	dup(?)
.data
	F0	db	'0', 0
	F1	db	'1', 0
	NL	db	0ah
.code
main PROC
	push	3
	push	offset n
	call	StdIn
	push	offset n
	call	atoi	; read n as int 

	push	offset F0	; 14h
	push	offset F1	; 10h
	push	offset f0	; 0ch
	push	offset f1	; 8h
	call	initialize

	push	eax			; eax = int (n) 14h
	push	offset f0	; 10h
	push	offset f1	; 0ch
	push	offset f2	; 8h
	call	fibprint
	ret
main ENDP

fibprint PROC
	push	ebp
	mov		ebp, esp
	push	ecx
	mov		ecx, [ebp + 14h]	; loop n times
	@print1:
		push	[ebp + 0ch]		; print f1
		call	println
		dec		ecx
		test	ecx, ecx
		jz		@finish
	@print:
		push	[ebp + 8h]			; f2 = f0 + f1
		push	[ebp + 10h]
		push	[ebp + 0Ch]
		call	sum
		push	[ebp + 8h]
		call	println
		dec		ecx
		test	ecx, ecx
		jz		@finish

		push	[ebp + 10h]
		push	[ebp + 8h]			; f0 = f2 + f1
		push	[ebp + 0Ch]
		call	sum
		push	[ebp + 10h]
		call	println
		dec		ecx
		test	ecx, ecx
		jz		@finish

		push	[ebp + 0Ch]
		push	[ebp + 8h]			; f1 = f2 + f0
		push	[ebp + 10h]
		call	sum
		push	[ebp + 0Ch]
		call	println
		dec		ecx
		test	ecx, ecx
		jz		@finish
		jmp		@print
	@finish:
	pop		esi
	pop		ecx
	mov		esp, ebp
	pop		ebp
	ret		10h
fibprint ENDP

initialize PROC	; f1 = '1' f0 = '0'
	push	ebp
	mov		ebp, esp
	push	[ebp + 0ch]
	push	[ebp + 14h]
	push	[ebp + 14h]
	call	sum			; f0 = '0'
	push	[ebp + 8h]
	push	[ebp + 0ch]
	push	[ebp + 10h]
	call	sum			; f1 = '1'
	mov		esp, ebp
	pop		ebp
	ret		10h
initialize ENDP

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

rev PROC ; parameter: offset buf
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

println PROC	; print with linefeed
	push	ebp
	mov		ebp, esp
	push	ecx
	push	[ebp + 8h]
	call	StdOut
	push	offset NL
	call	StdOut
	pop		ecx
	mov		esp, ebp
	pop		ebp
	ret		4h
println ENDP
end main
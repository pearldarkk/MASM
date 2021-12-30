.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
	s	db	105	dup(?)
	s1	db	11	dup(?)
	v	dd	100	dup(?)
	n	dd	1	dup(?)
	tmp	db	10	dup(?)
.data
	buf1	db	"s = ", 0
	buf2	db	"c = ", 0
	NL		db	0Ah, 0
	spc		db	20h
.code
main PROC
	push	offset buf1
	call	StdOut
	push	105
	push	offset s
	call	StdIn
	push	offset buf2
	call	StdOut
	push	11
	push	offset s1
	call	StdIn

	xor		eax, eax
	xor		edx, edx
	lea		esi, v
	@ss:
		push	offset s
		push	offset s1
		push	eax
		call	pos
		cmp		eax, -1
		jz		@finish
		mov		dword ptr [esi + 4h * edx], eax
		inc		edx			; count substrings
		inc		eax			; ecx = eax + 1
		jmp		@ss
	@finish:
		mov		n, edx
		push	n
		push	offset tmp
		call	itoa
		push	eax
		call	println	
		push	offset tmp
		push	n
		push	offset v
		call	printArray
	ret
main ENDP

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
	add		edi, 9h
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

pos PROC	; return in eax first position of substring para2 in source string para1 from index para3, if not return -1
	push	ebp
	mov		ebp, esp
	push	esi
	push	edi
	push	ecx
	push	edx
	mov		esi, [ebp + 10h]		; source string
	mov		edi, [ebp + 0Ch]		; substring
	add		esi, [ebp + 8h]			; find from index...
	@start:
		xor		ecx, ecx
		jmp		@check
	@check:
		mov		dh, byte ptr [edi + ecx]
		cmp		dh, 0
		jz		@found
		mov		dl, byte ptr [esi + ecx]
		cmp		dl, 0
		jz		@notfound
		inc		ecx
		cmp		dl, dh
		je		@check
		inc		esi
		jmp		@start
		@found:
			sub		esi, [ebp + 10h]
			mov		eax, esi	; res
			jmp		@finish
		@notfound:
			mov		eax, -1
			jmp		@finish
	@finish:
		pop		edx
		pop		ecx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
	ret		0Ch
pos ENDP

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

printArray PROC	;para1 = num, para2 = offset vector, para3 = string 
	push	ebp
	mov		ebp, esp
	push	ecx
	push	esi
	mov		ecx, [ebp + 0Ch]	; loop
	mov		esi, [ebp + 8h]
	@print:
		push	dword ptr [esi]
		push	[ebp + 10h]
		call	itoa
		push	eax
		call	print
		add		esi, 4
		loop	@print
	pop		esi
	pop		ecx
	mov		esp, ebp
	pop		ebp
	ret		0Ch
printArray ENDP
end main
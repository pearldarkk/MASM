.386
.model flat, stdcall
option casemap: none
.stack 4096

include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data?
	buf	db	32	dup(?)
.code
main PROC
	push	32
	push	offset buf
	call	StdIn

	push	offset buf
	call	rev

	push	offset buf
	call	StdOut
	ret
main ENDP

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
		mov		byte ptr[esi], dl
		inc		esi	
		loop	@revL
	pop		ecx
	pop		edx
	pop		esi
	mov		esp, ebp
	pop		ebp
	ret		4
rev ENDP
END main
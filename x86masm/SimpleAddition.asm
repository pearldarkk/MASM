.386
.model flat, stdcall
option casemap: none

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
	push	offset s
	push	eax
	call	itoa
	
	push	eax
	call	StdOut

	push    0
    call    ExitProcess
main ENDP

atoi PROC 
	push	ebp
	mov		ebp, esp
	push    esi
    push    edx
    push    ebx
    mov     esi, [ebp + 8]

    xor     eax, eax
    xor     edx, edx
    mov     ebx, 10
    iter:                       ; get each char and add to int value
    mul     ebx
    mov     dl, byte ptr [esi]
    inc     esi
    cmp     dh, dl              ; check for null byte
    jz      done
    and     dl, 0fh             ; clear first 4 bits to get (dec) char
    add     eax, edx        
    jmp     iter

    done:
    div     ebx                 
    pop     ebx
    pop     edx
    pop     esi
    mov     esp, ebp
    pop     ebp
    ret     4                   ; callee cleans stack
atoi ENDP

itoa PROC	
	push	ebp
	mov		ebp, esp
    push    edi
    push    edx
    push    ebx
    mov     edi, [ebp + 0ch]   
    add     edi, 8
    mov     eax, [ebp + 8]

    mov     ebx, 10
    iter:
    xor     edx, edx            ; clear to prepare for division
    div     ebx                 ; edx = eax % ebx, eax /= ebx
    or      dl, 30h             ; set 3rd and 4th bit to convert from dec to ascii
    mov     byte ptr [edi], dl  ; save to string
    dec     edi
    test    eax, eax            ; if finished
    jz      done
    jmp     iter

    done:
    inc     edi             
    mov     eax, edi
    pop     ebx
    pop     edx
    pop     edi
	mov		esp, ebp
	pop		ebp
	ret		8
itoa ENDP
end main
.386
.model flat, stdcall
option casemap: none

include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib

.data?
	buf db 32 dup(?)				; Reserve 32 bytes
.code
main PROC
	push    32
    push    offset buf
    call    StdIn

    push    offset buf
	call	toUpper                 ; convert to uppercase

	push    offset buf
    call    StdOut

	push    0
    call    ExitProcess
main ENDP

toUpper PROC
    push    ebp 
    mov     ebp, esp
    push    esi
    push    edi
    mov     esi, [ebp + 8]
    mov     edi, [ebp + 8]

    xor     eax, eax
    cld                             ; set df = 0 to set loop direction

    iter:
    lodsb                           ; al = byte ptr [esi]++ 
    cmp     al, ah
    jz      done
    and     al, 0dfh                 
    stosb                           ; byte ptr [edi]++ = al
    jmp     iter                    ; if uppercase continue

    done:
    mov     eax, [ebp + 8]
    pop     edi
    pop     esi
    mov     esp, ebp
    pop     ebp
    ret     4
toUpper ENDP
end main
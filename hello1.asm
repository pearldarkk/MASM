.386
.model flat, stdcall
option casemap: none

include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data?
	buf db 32 dup(?) ; reserve 32 bytes

.code
main PROC
	push    32
    push    offset buf
    call    StdIn

    push    offset buf
    call    StdOut

    ret
main ENDP
end main
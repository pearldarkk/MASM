.386
.model flat, stdcall

option casemap: none
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.code
main proc
    push    -11
    call    GetStdHandle
    push    eax
main endp
end main
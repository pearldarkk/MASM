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
    mov     ebp, esp
    sub     esp, 10h

	push    -10                 ; STD_INPUT_HANDLE
    call    GetStdHandle

    push    32  
    push    offset buf
    push    eax
    call    ReadFile            ; ReadFile(hConsoleInput, &buf, sizeof buf)

    push    -11                 ;STD_OUTPUT_HANDLE
    call    GetStdHandle

    push    32  
    push    offset buf
    push    eax
    call    WriteFile           ; WriteFile(hConsoleOutput, &buf, sizeof buf)

    push    0
    call    ExitProcess
main ENDP
end main
.386
.model flat, stdcall
option casemap: none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.data
    sHello  db  'Hello, World!', 0

.code
main proc
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle

    push    0
    push    ebx
    push    sizeof sHello
    push    offset sHello
    push    eax
    call    WriteConsole

    push    0
    call    ExitProcess
main endp
end main
    

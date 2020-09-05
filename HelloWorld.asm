.386

.model flat, stdcall
option casemap: none

include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
	msg db "Hello, World!", 0

.code
main PROC
	invoke StdOut, offset msg
	invoke ExitProcess, 0
main ENDP
end main
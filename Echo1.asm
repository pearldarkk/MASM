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
	buf db 32 dup(?) ; reserve 32 bytes

.code
main PROC
	invoke StdIn, offset buf, 32 ; Get user input max 32 bytes
	invoke StdOut, offset buf ; Print to stdout

	invoke ExitProcess, 0
main ENDP
end main
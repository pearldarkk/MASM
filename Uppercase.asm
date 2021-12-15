.386
.model flat, stdcall
option casemap: none

include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\user32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib
includelib C:masm32\lib\user32.lib

.data?
	buf db 32 dup(?)				; Reserve 32 bytes
.code
main PROC
	invoke	StdIn, offset buf, 32	; Get user input max 32 bytes

	call	toUpper ; convert to uppercase

	invoke	StdOut, offset buf		; print buf to stdout
	invoke	ExitProcess, 0			; exit return 0
main ENDP

toUpper PROC
	mov		esi, 0					; string index
	@loop:
		mov		al, buf[esi]	; move char to al
		cmp		al, 0			; compare with 0 (end of string)
		jz		@break			; if true return
		cmp		al, 'a'			; compare char with 'a'
		jl		@nextChar		; if less than 'a' -> not lowercase
		cmp		al, 'z'			; compare char with 'z'
		jg		@nextChar		; if greater than 'z' -> not lowercase
		sub		al, 20h			; lowercase for sure -> convert to upper
		mov		buf[esi], al	; again move back to buf
		@nextChar:
			inc		esi			; increase index
			jmp		@loop		; loop
		@break:
			ret					; return string
toUpper ENDP
end main
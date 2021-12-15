option casemap: none
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
	sErr			db	'Error! Try again...', 0Ah, 0
.data?
	hProcessSnap	dq	?
	PROCESSENTRY32 struct
		dwSize
	pe32			PROCESSENTRY32	?

.code
main PROC ; Kill process of 3 browser: Edge, Chrome, Firefox
	; take snapshot of all processes in system
takeProcessSnapshot:
	push	0
	push	2 ; TH32CS_SNAPPROCESS
	call	CreateToolhelp32Snapshot
	mov		hProcessSnap, rax

	; if fails
	cmp		rax, INVALID_HANDLE_VALUE
	je		errExit
	
	mov		pData.dwSize, sizeof pData



errExit:
	push	hProcessSnap
	call	CloseHandle
	mov		rax, offset sErr
	push	rax
	;call	StdOut
	ret

main ENDP

END
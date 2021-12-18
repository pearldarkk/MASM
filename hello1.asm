option casemap: none

extern GetStdHandle: proc

.data
	cap		db	'Message', 0
	msg		db	'Hello World', 0Ah, 0

.code
PUBLIC main
main PROC
	mov		rcx, -11
	call	GetStdHandle
	ret

main ENDP
end
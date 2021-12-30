extrn   GetStdHandle: proc
extrn   ReadFile: proc
extrn   WriteFile: proc
extrn   ExitProcess: proc

.data?
    string  db  256 dup(?)
    nByte   db  1   dup(?)
.code
main proc
    mov     rbp, rsp
    sub     rsp, 28h        ; shadow space + align
    mov     ecx, -10        ; STD_INPUT_HANDLE
    call    GetStdHandle
    mov     rcx, rax
    mov     rdx, offset string
    mov     r8,  256
    mov     r9, offset nByte
    mov     rbx, 0
    mov     [rsp + 20h], rbx    ; 5th qword above return address (4 dq = shadow space)
    call    ReadFile        ; get userinput for string

    mov     rcx, offset string
    call    reverse
    mov     r8, rax  ; strlen(string)

    mov     ecx, -11
    call    GetStdHandle    ; STD_OUTPUT_HANDLE
    mov     rcx, rax
    mov     rdx, offset string
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx
    call    WriteFile
    
    mov     ecx, 0
    call    ExitProcess
main endp

reverse proc    ; reverse(str) use stack to reverse the string str, return strsize in rax
    push    rbp
    mov     rbp, rsp  
    push    rsi             ; rsi rdi = nonvolatile register 
    push    rdi
    mov     rsi, rcx
    mov     rdi, rcx
    xor     ax, ax
    xor     rcx, rcx
    cld                     ; clear direction flag DF
    
    iterPush:               ; iterate string and push to stack
    lodsb                   ; al = byte ptr [rsi]++
    cmp     al, 0dh         ; check for /r = end of data
    jng     startPop
    push    ax              ; push 16bit
    inc     cx
    jmp     iterPush

    startPop:
    mov     rdx, rcx
    sub     rsi, rdi
    iterPop:                ; pop back
    pop     ax
    stosb                   ; byte ptr [rdi]-- = al
    dec     cx
    test    cx, cx
    jz      done
    jmp     iterPop
    
    done:
    mov     rax, rsi
    inc     rax             ; count /n 
    pop     rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret  
reverse endp
end 
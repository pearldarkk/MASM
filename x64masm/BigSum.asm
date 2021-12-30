extrn   GetStdHandle: proc
extrn   ReadFile: proc
extrn   WriteFile: proc
extrn   ExitProcess: proc
extrn   GetProcessHeap: proc
extrn   HeapAlloc: proc
extrn   HeapFree: proc

.data?
    num1    db  22    dup(?)
    num2    db  22    dup(?)
    sum     db  22    dup(?)
    nByte   dd  ?

.code
main proc
    mov     rbp, rsp
    sub     rsp, 28h

    mov     ecx, -10            ; STD_INPUT_HANDLE
    call    GetStdHandle
    mov     r12, 0
    mov     rcx, rax
    mov     rdx, offset num1
    mov     r8,  22
    mov     r9, offset nByte
    mov     [rsp + 20h], r12    ; 5th qword above return address (4 dq = shadow space)
    call    ReadFile

    mov     ecx, -10            ; STD_INPUT_HANDLE
    call    GetStdHandle
    mov     r12, 0
    mov     rcx, rax
    mov     rdx, offset num2
    mov     r8,  22
    mov     r9, offset nByte
    mov     [rsp + 20h], r12    ; 5th qword above return address (4 dq = shadow space)
    call    ReadFile

    mov     rcx, offset num1
    mov     rdx, offset num2
    mov     r8, offset sum
    call    bigSum
    push    rcx                 ; save strlen
    mov     ecx, -11            ; STD_INPUT_HANDLE
    call    GetStdHandle
    mov     r12, 0
    mov     rdx, offset sum
    pop     rcx
    mov     r8w, 0a0dh          
    mov     word ptr [rdx + rcx], r8w 
    add     rcx, 2              ; appended /r /n
    mov     r8, rcx
    mov     rcx, rax
    mov     r9, offset nByte
    mov     [rsp + 20h], r12    ; 5th qword above return address (4 dq = shadow space)
    call    WriteFile

    mov     ecx, 0
    call    ExitProcess
main endp

bigSum proc     ; bigSum(op1, op2, res) performs a arthmetic sum for BigInteger and stores the result in res, return &sum in rax, strlen(&sum) in rcx
    push    rbp
    mov     rbp, rsp
    sub     rsp, 18h   
    push    rdi
    push    rsi
    push    rbx
    mov     [rbp - 8], rcx
    mov     [rbp - 10h], rdx
    mov     [rbp - 18h], r8   
    call    reverse                 ; reverse(op1)
    mov     rcx, [rbp - 10h]   
    call    reverse                 ; reverse(op2)
    mov     rdx, [rbp - 18h]        ; rdx = res
    mov     rsi, [rbp - 10h]        ; rsi = op2
    mov     rdi, [rbp - 8]          ; rdi = op1
    xor     rax, rax
    xor     r8, r8
    mov     bh, 30h
    mov     bl, 0ah
    
    calc:
    mov     cl, byte ptr [rsi + r8]
    cmp     cl, 0dh
    jz      swap                    ; if one string's shorter, swap 
    sub     cl, bh
    mov     ah, cl                  ; + carry of the previous 
    mov     cl, byte ptr [rdi + r8]
    cmp     cl, 0dh
    jz      load                    ; if this is the longer string, load the rest (with carry) to complete
    sub     cl, bh
    add     al, cl                  ; digit2 + carry
    add     al, ah                  ; digit1 + digit2
    xor     ah, ah                  ; prepare div
    div     bl                
    add     ah, bh                  ; char(remainder)
    mov     cl, ah
    mov     byte ptr [rdx + r8], cl
    inc     r8
    jmp     calc
    
    swap:
    xchg    rsi, rdi
    
    load:
    mov     cl, byte ptr [rsi + r8]
    add     al, cl                  ; + carry of the previous sum calc
    cmp     al, 0dh                  ; meets end and have no carry
    jz      finish
    cmp     al, bh
    jl      carry                   ; if still have carry
    sub     al, bh
    xor     ah, ah
    div     bl
    add     ah, bh              
    mov     cl, ah
    mov     byte ptr [rdx + r8], cl
    inc     r8
    jmp     load
    
    carry:
    add     al, 23h                ; 0xd + carry + 0x23 = char(carry)
    mov     byte ptr [rdx + r8], al
    finish:
    mov     rcx, [rbp - 8]
    call    reverse             ; reverse(op1)
    mov     rcx, [rbp - 10h]       
    call    reverse             ; reverse(op2)
    mov     rcx, [rbp - 18h]
    call    reverse             ; reverse(sum)   
    mov     rcx, rax
    mov     rax, [rbp - 18h]   
    pop     rbx
    pop     rsi
    pop     rdi
    mov     rsp, rbp
    pop     rbp
    ret
bigSum endp

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
    dec     rax
    pop     rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret  
reverse endp
end
; stores functions used frequently
atoi proc                   ; ascii to int
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8
    push    rsi
    push    rbx
    mov     [rbp - 8], rcx     
    mov     rsi, rcx
    xor     ecx, ecx
    xor     eax, eax
    mov     ebx, 10
    
    iter:
    mul     ebx
    mov     cl, byte ptr [rsi]
    inc     rsi
    cmp     cl, '0'
    js      done
    cmp     cl, '9'
    jg      done
    and     cl, 0fh
    add     eax, ecx
    jmp     iter

    done:
    div     ebx
    pop     rbx
    pop     rsi
    mov     rsp, rbp
    pop     rbp    
    ret  
atoi endp

atol proc                   ; ascii to ull
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8
    push    rsi
    push    rbx
    mov     [rbp - 8], rcx     
    mov     rsi, rcx
    xor     rcx, rcx
    xor     rax, rax
    mov     rbx, 10
    
    iter:
    mul     rbx
    mov     cl, byte ptr [rsi]
    inc     rsi
    cmp     cl, '0'
    js      done
    cmp     cl, '9'
    jns     done
    and     cl, 0fh
    add     rax, rcx
    jmp     iter

    done:
    div     rbx
    pop     rbx
    pop     rsi
    mov     rsp, rbp
    pop     rbp    
    ret  
atol endp

itoa proc   ; int to ascii, return strlen in rcx, pointer in rax
    push    rbp    
    mov     rbp, rsp
    push    rsi
    push    rcx
    
    ; dynamic memory allocation to make room to create string
    sub     rsp, 20h            ; shadow space 
    call    GetProcessHeap
    mov     rcx, rax
    mov     rdx, 8
    mov     r8, 11
    call    HeapAlloc           ; HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, 10) 
    add     rsp, 20h
    mov     rdi, rax            
    add     rdi, 9              ; rdi = *(str + 9)
    pop     rax                 ; pop int to rax
    mov     r10, rdi            ; save rdi
    mov     r8d, 10
    
    iter:
    xor     edx, edx
    div     r8d
    or      dl, 30h
    mov     [rdi], dl
    dec     rdi
    test    eax, eax
    jz      done
    jmp     iter

    done:
    sub     r10, rdi
    mov     rcx, r10
    inc     rdi
    mov     rax, rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret   
itoa endp

ltoa proc   ; long long (64bit integer) to ascii, return strlen in rcx, pointer in rax
    push    rbp    
    mov     rbp, rsp
    push    rsi
    push    rcx
    
    ; dynamic memory allocation to make room to create string
    sub     rsp, 20h            ; shadow space 
    call    GetProcessHeap
    mov     rcx, rax
    mov     rdx, 8
    mov     r8, 22
    call    HeapAlloc           ; HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, 10) 
    add     rsp, 20h
    mov     rdi, rax            
    add     rdi, 20              ; rdi = *(str + 20)
    pop     rax                 ; pop int to rax
    mov     r10, rdi            ; save rdi
    mov     r8, 10
    
    iter:
    xor     rdx, rdx
    div     r8
    or      dl, 30h
    mov     byte ptr [rdi], dl
    dec     rdi
    test    rax, rax
    jz      done
    jmp     iter

    done:
    sub     r10, rdi
    mov     rcx, r10
    inc     rdi
    mov     rax, rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret   
ltoa endp

pos proc    ; pos(substr, str, i) return in eax first position of substring substr in source string str from index i, if fail return -1
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8h                 ; leaf func -> no need to align
    push    rsi
    push    rdi
    mov     [rbp - 8], rdx
    mov     rsi, rdx
    add     rsi, r8                 ; start from index i
    mov     rdi, rcx
    
    iter:                           ; iterate through string and perform strcmp 
    xor     rcx, rcx
    strcmp:         
    mov     dh, [rdi + rcx]
    cmp     dh, 0dh                  
    jz      found                   ; meet end of substr
    mov     dl, [rsi + rcx]
    cmp     dl, 0dh
    jz      notfound                ; meet end of str
    inc     rcx
    cmp     dh, dl
    je      strcmp
    inc     rsi                     ; next loop
    jmp     iter
    
    found:
    sub     rsi, [rbp - 8]
    mov     eax, esi    ; res
    jmp     finish
    notfound:
    mov     eax, -1

    finish:
    pop     rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret 
pos endp

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
extrn WriteFile: proc
extrn ReadFile: proc
extrn ExitProcess: proc
extrn GetStdHandle: proc
extrn GetProcessHeap: proc
extrn HeapAlloc: proc

.data?
    buffer  db  10000   dup(?)
    szArr   dd  ?  
    arr     dd  100     dup(?)
    oddSum  dq  ?
    evenSum dq  ?
    nByte   dd  ?
.data
    sSizeReq    db  'Nhap kich thuoc mang n: ', 0
    sArrReq     db  'Nhap n phan tu cua mang: ', 0
    sEvenSum    db  'Tong cac phan tu chan: ', 0
    sOddSum     db  'Tong cac phan tu le: ', 0
.code
main proc
    mov     rbp, rsp
    sub     rsp, 48h

    mov     rcx, -10
    call    GetStdHandle
    mov     [rbp - 8], rax      ; hInput
    mov     rcx, -11
    call    GetStdHandle
    mov     [rbp - 10h], rax    ; hOutput
    xor     r12, r12

    ; Get size of array
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sSizeReq
    mov     r8, sizeof sSizeReq
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, [rbp - 8h]
    mov     rdx, offset buffer
    mov     r8, 10
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    ReadFile
    mov     rcx, offset buffer
    call    atoi
    mov     szArr, eax

    ; Get n elements of array
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sArrReq
    mov     r8, sizeof sArrReq
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    
    xor     rbx, rbx
    getArrayBuffer:                   ; get element until receives n elements
    mov     rcx, [rbp - 8h]
    mov     rdx, offset buffer
    mov     r8, 10000
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    ReadFile
    
    mov     rcx, offset buffer
    mov     r13, offset arr
    getElement:                 ; separate buffer to get elements
    push    rcx
    call    atoi
    mov     dword ptr [r13 + rbx*4], eax
    inc     ebx
    cmp     szArr, ebx              
    je      doneGetArray        ; got enough elements
    pop     rcx
    iterBuffer:
    cmp     byte ptr [rcx], 0dh
    jz      getArrayBuffer
    inc     rcx
    cmp     byte ptr [rcx - 1], 20h
    je      getElement
    jmp     iterBuffer

    doneGetArray:               ; start calculating sum
    mov     ecx, 0
    mov     rdx, offset arr
    mov     r8, 0
    mov     r9, 0
    checkIndex:
    mov     r10d, dword ptr [rdx]
    test    ecx, 1b
    jz      calcEvenSum
    add     r9, r10             ; else it is odd-index
    jmp     iterate
    calcEvenSum:
    add     r8, r10
    iterate:
    add     rdx, 4
    inc     ecx
    cmp     ecx, szArr
    jnz     checkIndex      
    ; end loop
    mov     evenSum, r8
    mov     oddSum, r9

    ; println(evenSum)
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sEvenSum
    mov     r8, sizeof sEvenSum
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, evenSum  
    call    ltoa
    mov     r8w, 0a0dh          ; little-endian
    mov     word ptr [rax + rcx], r8w 
    add     rcx, 2              ; appended /r /n 
    mov     r8, rcx
    mov     rcx, [rbp - 10h]
    mov     rdx, rax
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile

    ; println(oddSum)
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sOddSum
    mov     r8, sizeof sOddSum
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, oddSum
    call    ltoa
    mov     r8w, 0a0dh          ; little-endian
    mov     word ptr [rax + rcx], r8w 
    add     rcx, 2              ; appended /r /n 
    mov     r8, rcx
    mov     rcx, [rbp - 10h]
    mov     rdx, rax
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile

    mov     ecx, 0
    call    ExitProcess
main endp

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
end
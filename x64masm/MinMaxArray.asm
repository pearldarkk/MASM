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
    min     dd  ?
    max     dd  ?
    nByte   dd  ?
.data
    sSizeReq    db  'Nhap kich thuoc mang n: ', 0
    sArrReq     db  'Nhap n phan tu cua mang: ', 0
    sMinResult  db  'Min: ', 0
    sMaxResult  db  'Max: ', 0
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

    ; Get elements of array
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

    doneGetArray:
    mov     rcx, offset arr
    mov     edx, szArr
    mov     r8, offset min
    call    findMin
    mov     rcx, offset arr
    mov     edx, szArr
    mov     r8, offset max
    call    findMax

    ; println(min)
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sMinResult
    mov     r8, sizeof sMinResult
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     ecx, min  
    call    itoa
    mov     r8w, 0a0dh          ; little-endian
    mov     word ptr [rax + rcx], r8w 
    add     rcx, 2              ; appended /r /n 
    mov     r8, rcx
    mov     rcx, [rbp - 10h]
    mov     rdx, rax
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile

    ; println(max)
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sMaxResult
    mov     r8, sizeof sMaxResult
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     ecx, max  
    call    itoa
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

findMin proc                 ; findMin(&arr, sizeof arr, &min) return array's min value in &min
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8
    push    rbx
    mov     [rbp - 8], r8           ; min
    mov     r8d, 0ffffffffh
    xor     rbx, rbx
    compare:
    cmp     dword ptr [rcx], r8d    ; < min
    jb      isMin
    iterate:
    add     rcx, 4
    inc     ebx
    cmp     ebx, edx
    je      finish
    jmp     compare
    isMin:
    mov     r8d, dword ptr [rcx]    ; min = arr[i]
    jmp     iterate

    finish:
    mov     ebx, r8d
    mov     r8, [rbp - 8]
    mov     dword ptr [r8], ebx
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret
findMin endp

findMax proc                 ; findMax(&arr, sizeof arr, &max) return array's max value in &max
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8
    push    rbx
    mov     [rbp - 8], r8           ; max
    mov     r8d, 0

    xor     rbx, rbx
    compare:
    cmp     dword ptr [rcx], r8d    ; > max
    ja      isMax
    iterate:
    add     rcx, 4
    inc     ebx
    cmp     ebx, edx
    je      finish
    jmp     compare
    isMax:
    mov     r8d, dword ptr [rcx]    ; max = arr[i]
    jmp     iterate

    finish:
    mov     ebx, r8d
    mov     r8, [rbp - 8]
    mov     dword ptr [r8], ebx
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret
findMax endp

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
end
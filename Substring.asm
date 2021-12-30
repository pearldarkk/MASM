extrn   GetStdHandle: proc
extrn   ReadFile: proc
extrn   WriteFile: proc
extrn   ExitProcess: proc
extrn   GetProcessHeap: proc
extrn   HeapAlloc: proc
extrn   HeapFree: proc

.data?
    string      db  102 dup(?)
    substring   db  12  dup(?)
    nByte       dd  ?
    arr         db  100 dup(?)
    szArr       dd  ?
.data
    strReq      db  'S = ', 0
    substrReq   db  'C = ', 0

.code
main proc
    mov     rbp, rsp
    sub     rsp, 38h        ; shadow space + align + local variable
    
    mov     ecx, -10        ; STD_INPUT_HANDLE
    call    GetStdHandle
    mov     [rbp - 8], rax
    mov     ecx, -11
    call    GetStdHandle    ; STD_OUTPUT_HANDLE
    mov     [rbp - 10h], rax
    mov     rbx, 0
    
    ;get user input for string
    mov     rcx, [rbp - 10h]
    mov     rdx, offset strReq
    mov     r8, 4
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx
    call    WriteFile
    mov     rcx, [rbp - 8]
    mov     rdx, offset string
    mov     r8,  102
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx    ; 5th qword above return address (4 dq = shadow space)
    call    ReadFile            ; ReadFile(hOutput, &string, 4, &nByte, 0)

    ; get user input for substring
    mov     rcx, [rbp - 10h]
    mov     rdx, offset substrReq
    mov     r8, 4
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx
    call    WriteFile
    mov     rcx, [rbp - 8]
    mov     rdx, offset substring
    mov     r8,  12
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx   
    call    ReadFile           

    ; start counting
    xor     eax, eax
    mov     rdi, offset arr
    iterString:
    mov     rcx, offset substring
    mov     rdx, offset string
    movzx   r8, ax
    call    pos
    cmp     eax, -1
    jz      finish
    stosb                      
    inc     eax           
    jmp     iterString
    
    finish:
    ; println(count)
    mov     r8, offset arr
    sub     rdi, r8             ; find szArr
    mov     szArr, edi          ; save to szArr variable
    mov     ecx, szArr
    call    itoa
    mov     r8w, 0a0dh          ; little-endian
    mov     word ptr [rax + rcx], r8w 
    add     rcx, 2              ; appended /r /n 
    mov     r8, rcx             
    mov     rcx, [rbp - 10h]
    mov     rdx, rax
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx
    call    WriteFile           
    
    ;print array arr
    mov     rsi, offset arr
    mov     r12d, szArr
    iterArray:
    lodsb                   ; al = byte ptr [rsi++]
    movzx   ecx, al
    call    itoa            ; convert each element to ascii
    ; append ' ' 
    mov     r8b, 20h
    mov     byte ptr [rax + rcx], r8b 
    add     rcx, 1          
    mov     r8, rcx
    mov     rcx, [rbp - 10h]
    mov     rdx, rax
    mov     r9, offset nByte
    mov     [rsp + 20h], rbx
    call    WriteFile           ; print(i + ' ')
    dec     r12d
    test    r12d, r12d
    jnz     iterArray

    mov     ecx, 0
    call    ExitProcess
main endp

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

itoa proc   ; int to ascii, return szArr in rcx, pointer in rax
    push    rbp    
    mov     rbp, rsp
    push    rsi
    push    rcx
    
    ; dynamic memory allocation to make room to create string
    sub     rsp, 20h            ; shadow space + align
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
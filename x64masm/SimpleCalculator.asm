extrn WriteFile: proc
extrn ReadFile: proc
extrn ExitProcess: proc
extrn GetStdHandle: proc
extrn GetProcessHeap: proc
extrn HeapAlloc: proc

.data?
    operand1    db  22  dup(?)
    operand2    db  22  dup(?)
    operator    db  ?
    result      dq  ?
    remainder   dq  ?
    nByte       dd  ?
    negResult   db  ?
.data
    sOperatorRequest db "Select operator:", 0Ah, "1. Addition", 0Ah, "2. Subtraction", 0Ah, "3. Multiplication", 0Ah, "4. Division", 0Ah, "0. Exit", 0Ah, "-> ", 0
    sOperandRequest  db "Input 2 operands in 2 separate lines: ", 0ah, 0
    sResultOutput    db "Result: ", 0
    sRemainderOutput db "Remainder: ", 0
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

    startCalculating:
    ; Get operator choice
    mov     negResult, 0
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sOperatorRequest
    mov     r8, sizeof sOperatorRequest
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, [rbp - 8h]
    mov     rdx, offset operator
    mov     r8, 3
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    ReadFile

    mov     dl, operator
    test    dl, '0'
    jnz     finish

    ; Get 2 operands
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sOperandRequest
    mov     r8, sizeof sOperandRequest
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, [rbp - 8h]
    mov     rdx, offset operand1
    mov     r8, 22
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    ReadFile
    mov     rcx, [rbp - 8h]
    mov     rdx, offset operand2
    mov     r8, 22
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    ReadFile    
                                    ; convert 2 operand to integer
    mov     rcx, offset operand1
    call    atol
    mov     r13, rax
    mov     rcx, offset operand2
    call    atol
    mov     r14, rax                ; r14 = op2, r13 = op1

    ; calculating...
    mov     dl, operator           
    sub     dl, '1'                ; implement switch-case
    jz      addition
    dec     dl
    jz      subtraction
    dec     dl
    jz      multiplication
    dec     dl
    jz      division
    ;default
    jmp     startCalculating

    addition:
    add     r13, r14
    mov     result, r13
    jmp     printResult

    subtraction:
    mov     rdx, r13        ; save r13
    sub     r13, r14
    js      NegativeResult
    mov     result, r13
    jmp     printResult
    NegativeResult:
    mov     negResult, 1
    mov     r13, rdx
    sub     r14, r13
    mov     result, r14
    jmp     printResult

    multiplication:
    mov     rax, r14
    mul     r13
    mov     result, rax
    jmp     printResult

    division:
    xor     rdx, rdx
    mov     rax, r13
    div     r14
    mov     result, rax
    mov     remainder, rdx

    printResult:
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sResultOutput
    mov     r8, sizeof sResultOutput
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, result
    call    ltoa            
    test    negResult, 1
    jnz     addSign
    continue:
    mov     r8w, 0a0dh          ; little-endian
    mov     word ptr [rax + rcx], r8w 
    add     rcx, 2              ; appended /r /n 
    mov     r8, rcx
    mov     rcx, [rbp - 10h]
    mov     rdx, rax
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile

    ; if division, print remainder
    mov     dl, operator
    cmp     dl, '4'
    je      printRemainder
    jmp     startCalculating
    
    printRemainder:
    mov     rcx, [rbp - 10h]
    mov     rdx, offset sRemainderOutput
    mov     r8, sizeof sRemainderOutput
    mov     r9, offset nByte
    mov     [rsp - 20h], r12
    call    WriteFile
    mov     rcx, remainder
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
    jmp     startCalculating    ; new loop

    addSign:
    dec     rax
    mov     byte ptr [rax], '-'
    inc     rcx
    jmp     continue

    finish:
    mov     ecx, 0
    call    ExitProcess
main endp

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
    jg      done
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
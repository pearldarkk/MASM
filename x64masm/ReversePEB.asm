.data?
    string  db  256 dup(?)
    nByte   db  1   dup(?)
.code
main proc
    mov     rbp, rsp
    sub     rsp, 48h        ; shadow space + align

    call    findkernel32
    mov     [rbp - 8], rax

    mov     rdx, 7487d823h        ; GetStdHandle
    mov     rcx, [rbp - 8]  
    call    findSymbol
    mov     [rbp - 10h], rax

    mov     ecx, -10        ; STD_INPUT_HANDLE
    call    rax
    mov     [rbp - 18h], rax    ; hInput
    mov     ecx, -11
    mov     rax, [rbp - 10h]
    call    rax
    mov     [rbp - 10h], rax    ; hOutput

    mov     rdx, 10fa6516h      ; ReadFile
    mov     rcx, [rbp - 8]
    call    findSymbol
    mov     rcx, [rbp - 18h]
    mov     rdx, offset string
    mov     r8, 256
    mov     r9, offset nByte
    call    rax

    mov     rcx, offset string
    call    reverse
    mov     [rbp - 20h], rax    ; store size

    mov     rdx, 0e80a791fh     ; WriteFile
    mov     rcx, [rbp - 8]
    call    findSymbol
    mov     rcx, [rbp - 10h]
    mov     rdx, offset string
    mov     r8, [rbp - 20h]
    mov     r9, offset nByte
    call    rax    

    mov     rdx, 73e2d87eh     ; ExitProcess
    mov     rcx, [rbp - 8]
    call    findSymbol
    mov     rcx, 0
    call    rax                 
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

findkernel32 proc
    push    rsi
    xor     rax, rax
    ;assume  fs:nothing
    mov     rax, gs:[rax + 60h]       ; eax = &PEB
    mov     rax, [rax + 18h]    ; eax = &(PEB->ldr)
    mov     rsi, [rax + 20h]    ; eax = &(Ldr.InMemoryOrderModuleList.Flink)
    lodsq           
    xchg    rax, rsi
    lodsq   
    mov     rax, [rax + 20h]    ; 3rd module (kernel32.dll) base address
    pop     rsi
    ret
findkernel32 endp

hashcalc proc
    push    rbp
    mov     rbp, rsp
    push    rsi
    push    rdi
    mov     rsi, rcx

    xor     edi, edi
    cld                     ; clear direction flag
    iterate:
    xor     eax, eax
    lodsb                   ; load string from byte ptr [rsi]++ to al
    cmp     al, ah          ; if byte ptr == 0 return (ah = 0)
    je      done
    ror     edi, 0dh        ; rotate right 13
    add     edi, eax        ; add current byte to hash value
    jmp     iterate

    done:
    mov     eax, edi
    pop     rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret     
hashcalc endp

findSymbol proc
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rsi
    sub     rsp, 10h
    mov     [rbp - 8], rcx
    mov     [rbp - 10h], rdx
    xor     rax, rax
    xor     rdx, rdx
    xor     rcx, rcx
    mov     rbx, [rbp - 8]                      ; dllBase
    mov     eax, [rbx + 3ch]                    ; PE signature offset
    add     rax, rbx                            ; rva -> va
    ; pe32 parsing
    mov     edx, [rax + 88h]                    ; pe offset + OptionalHeader + data directory
    add     rdx, [rbp - 8]                      ; edx = &IMAGE_EXPORT_DIRECTORY
    mov     ecx, [rdx + 18h]                    ; ecx = NumberOfNames
    mov     ebx, [rdx + 20h]                    ; ebx = AddressOfNames
    add     rbx, [rbp - 8]                      ; rva -> va

    searching:
    jecxz   nfound                              ; iterated through all functions in dll
    dec     ecx
    mov     esi, [rbx + rcx*4]                  ; next func name
    add     rsi, [rbp - 8]
    push    rcx
    mov     rcx, rsi
    call    hashcalc                            ; calc function hash
    pop     rcx
    cmp     eax, [rbp - 10h]                    ; compare 2 hash
    jnz     searching
    
    mov     ebx, [rdx + 24h]                    ; ordinal table rva
    add     rbx, [rbp - 8]
    mov     cx, [rbx + rcx*2]                   ; AddressOfNameOrdinals offset
    mov     ebx, [rdx + 1ch]                    ; ebx = AddressOfFunctions
    add     rbx, [rbp - 8]
    mov     eax, [rbx + rcx*4]                  ; function rva
    add     rax, [rbp - 8]                      ; rva -> va
    jmp     done

    nfound:
    xor     rax, rax                            ; if fails, retur 0

    done:
    pop     rsi
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret     
findSymbol endp
end 

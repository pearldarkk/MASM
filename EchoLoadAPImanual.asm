.386
.model flat, stdcall
option casemap: none
.code
main proc
    mov     ebp, esp
    sub     esp, 0ch
    call    abc
    db      32  dup('1')          ; assume buf

    abc:
    pop     ebx                 ; ebx = &buf
    call    findkernel32
    mov     [ebp - 4], eax      ; local [ebp-4] = kernel32 base address
    
    push    7487d823h           ; GetStdHandle hash value
    push    [ebp - 4]
    call    findSymbol          ; find function GetStdHandle

    push    eax
    push    -10                 ; STD_INPUT_HANDLE
    call    eax              
    mov     [ebp - 8], eax      ; hConsoleInput
    pop     eax
    push    -11
    call    eax
    mov     [ebp - 0ch], eax    ; hConsoleOutput

    push    10fa6516h           ; ReadFile hash value
    push    [ebp - 4]           
    call    findSymbol          

    push    32
    push    ebx
    push    [ebp - 8]
    call    eax                 ; ReadFile(hConsoleInput, &buf, 32)

    push    0e80a791fh           ; WriteFile hash value
    push    [ebp - 4]           
    call    findSymbol          

    push    32
    push    ebx
    push    [ebp - 0ch]
    call    eax                 ; WriteFile(hConsoleOutput, &buf, sizeof buf)

    push    73e2d87eh           ; ExitProcess hash value
    push    [ebp - 4]
    call    findSymbol

    push    0
    call    eax                 ; ExitProcess(0)
main endp

findkernel32 proc
    push    esi
    xor     eax, eax
    assume  fs:nothing
    mov     eax, [fs: 30h]       ; eax = &PEB
    mov     eax, [eax + 0ch]    ; eax = &(PEB->ldr)
    mov     esi, [eax + 14h]    ; eax = &(Ldr.InMemoryOrderModuleList.Flink)
    lodsd           
    xchg    eax, esi
    lodsd   
    mov     eax, [eax + 10h]    ; 3rd module (kernel32.dll) base address
    pop     esi
    ret
findkernel32 endp

hashcalc proc
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    mov     esi, [ebp + 8]

    xor     edi, edi
    cld                     ; clear direction flag
    iterate:
    xor     eax, eax
    lodsb                   ; load string from byte ptr [esi]++ to al
    cmp     al, ah          ; if byte ptr == 0 return (ah = 0)
    je      done
    ror     edi, 0dh        ; rotate right 13
    add     edi, eax        ; add current byte to hash value
    jmp     iterate

    done:
    mov     eax, edi
    pop     edi
    pop     esi
    mov     esp, ebp
    pop     ebp
    ret     4
hashcalc endp

findSymbol proc
    pushad
    mov     ebp, [esp + 0ch]                    ; restore esp value before pushad into ebp to create stack frame
    mov     ebx, [ebp + 4]                      ; dllBase
    mov     eax, [ebx + 3ch]                    ; PE signature offset
    add     eax, ebx                            ; rva -> va
    ; pe32 parsing
    mov     edx, [eax + 18h + 60h]              ; pe offset + OptionalHeader + data directory
    add     edx, ebx                            ; edx = &IMAGE_EXPORT_DIRECTORY
    mov     ecx, [edx + 18h]                    ; ecx = NumberOfNames
    mov     ebx, [edx + 20h]                    ; ebx = AddressOfNames
    add     ebx, [ebp + 4]                      ; rva -> va

    searching:
    jecxz   nfound                              ; iterated through all functions in dll
    dec     ecx
    mov     esi, [ebx + ecx*4]                  ; next func name
    add     esi, [ebp + 4]
    push    esi
    call    hashcalc                            ; calc function hash
    cmp     eax, [ebp + 8]                      ; compare 2 hash
    jnz     searching

    mov     ebx, [edx + 24h]                    ; ordinal table rva
    add     ebx, [ebp + 4]                      ; rva -> va
    mov     cx, [ebx + ecx*2]                   ; AddressOfNameOrdinals offset
    mov     ebx, [edx + 1ch]                    ; ebx = AddressOfFunctions
    add     ebx, [ebp + 4]                      ; rva -> va

    mov     eax, [ebx + ecx*4]                  ; function rva
    add     eax, [ebp + 4]                      ; rva -> va
    jmp     done

    nfound:
    xor     eax, eax                            ; if fails, retur 0

    done:
    mov     [esp + 1ch], eax                    ; overwrite eax stored on stack to popad
    popad
    ret     8
findSymbol endp
end main
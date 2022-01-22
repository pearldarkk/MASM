; export functions
extrn   ReadFile: proc
extrn   WriteFile: proc
extrn   ExitProcess: proc
extrn   CreateFileA: proc
extrn   GetFileSizeEx: proc
extrn   GetStdHandle: proc
extrn   GetProcessHeap: proc
extrn   HeapAlloc:  proc
extrn   HeapFree: proc
extrn   GetLastError: proc

.data
    isPE32                  db  0
    sRequestFileName        db  "Enter link to PE file: ", 0
    sErrorOutput            db  "Error occured!", 0
    sUnValidFileSignature   db  "Unvalid PE file.", 0
    ; DOS Header
    sDosHeader              db  0Ah, 0dh, "[!] DOS Header: ", 0ah, 0dh, 0
    sE_magic                db  "e_magic: ", 0
    sE_lfanew               db  "e_lfanew: ", 0
    ; PE header
    sNtHeader               db  0Ah, 0dh, "[!] NT Header: ", 0ah, 0dh, 0
    sSignature              db  "Signature: ", 0
    ; FILE_HEADER
    sFileHeader             db  0Ah, 0dh, "[!!] File Header: ", 0Ah, 0dh, 0
    sNumberOfSections       db  "NumberOfSections: ", 0
    sSizeOfOptionalHeader   db  "SizeOfOptionalHeader: ", 0
    sCharacteristics        db  "Characteristics: ", 0
    ; OPTIONAL_HEADER
    sOptionalHeader         db  0Ah, 0dh, "[!!] Optional Header: ", 0Ah, 0dh, 0
    sAddressOfEntryPoint    db  "AddressOfEntryPoint: ", 0
    sImageBase              db  "ImageBase: ", 0
    sSectionAlignment       db  "SectionAlignment: ", 0
    sFileAlignment          db  "FileAlignment: ", 0
    sSizeOfImage            db  "SizeOfImage: ", 0
    sSubsystem              db  "Subsystem: ", 0
    ; DATA_DIRECTORIES
    sDataDirectory          db  0Ah, 0dh, "[!!!] DataDirectory: ", 0Ah, 0dh, 0
    sExportRVA              db  "Export Directory RVA: ", 0
    sExportSize             db  "Export Directory size: ", 0
    sImportRVA              db  "Import Directory RVA: ", 0
    sImportSize             db  "Import Directory size: ", 0
    sRelocationRVA          db  "Relocation Directory RVA: ", 0
    sRelocationSize         db  "Relocation Directory size: ", 0
    sDebugRVA               db  "Debug Directory RVA: ", 0
    sDebugSize              db  "Debug Directory size: ", 0
    sTLSRVA                 db  "TLS Directory RVA: ", 0
    sTLSSize                db  "TLS Directory size: ", 0



    ; Section Table
    sSectionHeader          db  0ah, 0dh, "[!] Section Header: ", 0ah, 0dh, 0
    sName                   db  "Name: ", 0
    sVirtualAddress         db  "Virtual Address: ", 0
    sPointerToRawData       db  "Pointer To Raw Data: ", 0
    ; Export Directory
    sExportDirectory        db  0ah, 0dh, "[!] Export Directory: ", 0ah, 0dh, 0
    sNumberOfFunctions      db  "Number Of Functions: ", 0
    sNumberOfNames          db  "Number Of Names: ", 0
    sAddressOfFunctions     db  "Address Of Functions: ", 0
    sAddressOfNames         db  "Address Of Names: ", 0
    sAddressOfNameOrdinals  db  "Address Of Name Ordinals: ", 0
    sNameOrdinal            db  "Name Ordinal: ", 0   
    sFunction               db  "Function RVA: ", 0
    ; Import Directory
    sImportDirectory        db  0ah, 0dh, "[!] Import Directory: ", 0ah, 0dh, 0
    sDllName                db  0ah, 0dh, "[!!] Dll Name: ", 0
    sHint                   db  "Hint: ", 0
    sOrdinal                db  "Ordinal: ", 0

.data?
    lpFileName      db  512 dup(?)
    lpFileSize      dq  ?
    lpFileData      dq  ?
    nByte           dd  ?
    hStdIn          dq  ?
    hStdOut         dq  ?
    hexString       db  18  dup(?)

.code
main proc
    mov     rbp, rsp
    sub     rsp, 68h
    mov     r12, 0

    ; get stdio handles
    mov     ecx, -10        ; STD_INPUT_HANDLE
    call    GetStdHandle
    mov     hStdIn, rax
    mov     ecx, -11        ; STD_OUT_HANDLE
    call    GetStdHandle
    mov     hStdOut, rax

    ; get user input for filename and save in lpFileName (null-terminated)
    mov     rcx, hStdOut
    mov     rdx, offset sRequestFileName
    mov     r8, sizeof sRequestFileName
    mov     r9, offset nByte
    mov     [rsp + 20h], r12        ; push 0 to stack 
    call    WriteFile       
    mov     rcx, hStdIn
    mov     rdx, offset lpFileName
    mov     r8, 512 
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    ReadFile        
    mov     eax, nByte
    sub     eax, 2
    mov     rdx, offset lpFileName
    add     rdx, rax
    mov     word ptr [rdx], 0           ; clear /r/n at end of buffer

    ; open and read file
    mov     rcx, offset lpFileName
    mov     rdx, 80000000h          ; GENERIC_READ https://docs.microsoft.com/en-us/windows/win32/secauthz/access-mask-format?redirectedfrom=MSDN
    mov     r8, 1                   ; FILE_SHARE_READ
    mov     r9, 0  
    mov     r10, 3
    mov     [rsp + 20h], r10        ; OPEN_EXISTING
    mov     r10, 80h
    mov     [rsp + 28h], r10        ; FILE_ATTRIBUTE_NORMAL
    mov     [rsp + 30h], r9         ; NULL          
    call    CreateFileA             
    cmp     rax, -1                 ; if return INVALID_HANDLE_VALUE 
    jz      errorExit
    mov     [rbp - 8], rax          ; hFile

    ; if opened, alloc a buffer[filesize] to read file
    mov     rcx, rax                
    mov     rdx, offset lpFileSize
    call    GetFileSizeEx           ; GetFileSizeEx(hFile, &lpFileSize)
    call    GetProcessHeap
    mov     rcx, rax                
    mov     rdx, 8
    mov     r8, lpFileSize
    call    HeapAlloc               
    mov     lpFileData, rax         ; lpFileSize = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, lpFileSize)
    mov     rcx, [rbp - 8]
    mov     rdx, lpFileData
    mov     r8, lpFileSize
    mov     r9, offset nByte
    mov     [rsp + 20h], r12    
    call    ReadFile                ; ReadFile(hFile, lpFileData, lpFileSize, &nByte, NULL)
    
    ; begin parsing file
    mov     rbx, lpFileData
    _IMAGE_DOS_HEADER:              ; print out e_magic for file signature, e_lfanew for offset of PE Header
    mov     rcx, hStdOut
    mov     rdx, offset sDosHeader
    mov     r8, sizeof sDosHeader
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; e_magic
    mov     rcx, hStdOut
    mov     rdx, offset sE_magic
    mov     r8, sizeof sE_magic
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    movzx   rcx, word ptr [rbx]
    cmp     rcx, 5a4dh               ; compare with DOS signature
    jnz     errorExit
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; e_lfanew
    mov     rcx, hStdOut
    mov     rdx, offset sE_lfanew
    mov     r8, sizeof sE_lfanew
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 3ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    mov     edx, dword ptr [rbx + 3ch]
    add     rbx, rdx
    _IMAGE_NT_HEADER:               ; aka PE Header, contains Signature, File Header and Optional Header
    mov     rcx, hStdOut
    mov     rdx, offset sNtHeader
    mov     r8, sizeof sNtHeader
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; Signature
    mov     rcx, hStdOut
    mov     rdx, offset sSignature
    mov     r8, sizeof sSignature
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    add     rbx, 4
    _IMAGE_FILE_HEADER:             ; contains 20 bytes showing info about physical layout and file properties
    mov     rcx, hStdOut
    mov     rdx, offset sFileHeader
    mov     r8, sizeof sFileHeader
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; NumberOfSections
    mov     rcx, hStdOut
    mov     rdx, offset sNumberOfSections
    mov     r8, sizeof sNumberOfSections
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    movzx   rcx, word ptr [rbx + 2]
    mov     [rbp - 18h], rcx            ; save value for later use
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; SizeOfOptionalHeader
    mov     rcx, hStdOut
    mov     rdx, offset sSizeOfOptionalHeader
    mov     r8, sizeof sSizeOfOptionalHeader
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    movzx   rcx, word ptr [rbx + 10h]
    mov     [rbp - 8], rcx              ; save for later use
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; Characteristics
    mov     rcx, hStdOut
    mov     rdx, offset sCharacteristics
    mov     r8, sizeof sCharacteristics
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    movzx   rcx, word ptr [rbx + 12h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    add     rbx, 14h
    _IMAGE_OPTIONAL_HEADER:         
    mov     rcx, hStdOut
    mov     rdx, offset sOptionalHeader
    mov     r8, sizeof sOptionalHeader
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; AddressOfEntryPoint
    mov     rcx, hStdOut
    mov     rdx, offset sAddressOfEntryPoint
    mov     r8, sizeof sAddressOfEntryPoint
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 10h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; ImageBase
    mov     rcx, hStdOut
    mov     rdx, offset sImageBase
    mov     r8, sizeof sImageBase
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     r13, 1ch                    ; ->ImageBase
    cmp     word ptr [rbx], 10bh    ;   ->magic == 10b -> pe32
    jz      PE32ImageBase
    sub     r13, 4                      ; only pe32 has BaseOfData
    mov     rcx, qword ptr [rbx + r13]
    add     r13, 8
    jmp     continueImageBase

    PE32ImageBase:
    mov     isPE32, 1
    mov     ecx, dword ptr [rbx + r13]
    add     r13, 4

    continueImageBase:
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; SectionAlignment
    mov     rcx, hStdOut
    mov     rdx, offset sSectionAlignment
    mov     r8, sizeof sSectionAlignment
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + r13]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    add     r13, 4
    ; FileAlignment
    mov     rcx, hStdOut
    mov     rdx, offset sFileAlignment
    mov     r8, sizeof sFileAlignment
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + r13]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    add     r13, 14h                ; ->SizeOfImage
    ; SizeOfImage
    mov     rcx, hStdOut
    mov     rdx, offset sSizeOfImage
    mov     r8, sizeof sSizeOfImage
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + r13]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    add     r13, 0ch                ; ->Subsystem
    ; Subsystem
    mov     rcx, hStdOut
    mov     rdx, offset sSubsystem
    mov     r8, sizeof sSubsystem
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    movzx   rcx, word ptr [rbx + r13]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; move rbx to point to Data Directory
    mov     rdx, [rbp - 8]              ; SizeOfOptionalHeader
    mov     [rbp - 10h], rbx              ; save &OptionalHeader
    sub     rdx, 80h                    ; - sizeof DataDirectory
    add     rbx, rdx                    ; rbx = &DataDirectory
    _IMAGE_DATA_DIRECTORY:
    mov     rcx, hStdOut
    mov     rdx, offset sDataDirectory
    mov     r8, sizeof sDataDirectory
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; ExportRVA
    mov     rcx, hStdOut
    mov     rdx, offset sExportRVA
    mov     r8, sizeof sExportRVA
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx]
    mov     [rbp - 1ch], ecx            ; save exportRVA
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; ExportSize
    mov     rcx, hStdOut
    mov     rdx, offset sExportSize
    mov     r8, sizeof sExportSize
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 4]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; ImportRVA
    mov     rcx, hStdOut
    mov     rdx, offset sImportRVA
    mov     r8, sizeof sImportRVA
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 8]
    mov     [rbp - 20h], ecx            ; save importRVA
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; ImportSize
    mov     rcx, hStdOut
    mov     rdx, offset sImportSize
    mov     r8, sizeof sImportSize
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 0ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; RelocationRVA
    mov     rcx, hStdOut
    mov     rdx, offset sRelocationRVA
    mov     r8, sizeof sRelocationRVA
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 28h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; RelocationSize
    mov     rcx, hStdOut
    mov     rdx, offset sRelocationSize
    mov     r8, sizeof sRelocationSize
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 2ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; DebugRVA
    mov     rcx, hStdOut
    mov     rdx, offset sDebugRVA
    mov     r8, sizeof sDebugRVA
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 30h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; DebugSize
    mov     rcx, hStdOut
    mov     rdx, offset sDebugSize
    mov     r8, sizeof sDebugSize
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 34h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; TLSRVA
    mov     rcx, hStdOut
    mov     rdx, offset sTLSRVA
    mov     r8, sizeof sTLSRVA
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 48h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; TLSSize
    mov     rcx, hStdOut
    mov     rdx, offset sTLSSize
    mov     r8, sizeof sTLSSize
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 4ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    

    mov     rbx, [rbp - 10h]        ; rbx = &OptionalHeader
    add     rbx, [rbp - 8]          ; rbx += SizeOfOptinalHeader = SectionHeader
    mov     [rbp - 8], rbx          ; save &SectionHeader
    mov     r13, 0                  
    _IMAGE_SECTION_HEADER:          ; Section table is a array of IMAGE_SECTION_HEADERs
    mov     rcx, hStdOut
    mov     rdx, offset sSectionHeader
    mov     r8, sizeof sSectionHeader
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    nextSection:
    cmp     r13, [rbp - 18h]            ; cmp with NumberOfSections
    jz      _IMAGE_EXPORT_DIRECTORY

    ; Name
    mov     rcx, hStdOut
    mov     rdx, offset sName
    mov     r8, sizeof sName
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     rax, qword ptr [rbx]
    mov     rdi, offset hexString
    stosq
    mov     r8, 8
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; VirtualAddress
    mov     rcx, hStdOut
    mov     rdx, offset sVirtualAddress
    mov     r8, sizeof sVirtualAddress
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 0ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; PointerToRawData
    mov     rcx, hStdOut
    mov     rdx, offset sPointerToRawData
    mov     r8, sizeof sPointerToRawData
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 14h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; Characteristics
    mov     rcx, hStdOut
    mov     rdx, offset sCharacteristics
    mov     r8, sizeof sCharacteristics
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 24h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    add     rbx, 28h
    inc     r13
    jmp     nextSection

    _IMAGE_EXPORT_DIRECTORY:
    mov     rax, [rbp - 18h]        ; rax = number of sections
    mov     rbx, 28h
    mul     rbx    
    mov     rbx, [rbp - 8]          ; rbx = &section header
    add     rbx, rax                ; rbx = &section header + 28h * NumberOfSections = ExportDirectory

    mov     rcx, hStdOut
    mov     rdx, offset sExportDirectory
    mov     r8, sizeof sExportDirectory
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    mov     edx, dword ptr [rbp - 1ch]
    cmp     edx, 0          ;   exportRVA == 0 ?
    jz      _IMAGE_IMPORT_DESCRIPTOR

    ; get export offset
    mov     rcx, [rbp - 18h]
    mov     edx, dword ptr [rbp - 1ch]
    mov     r8, [rbp - 8]
    call    rvatooffset
    mov     rbx, lpFileData
    add     rbx, rax

    ; Name
    mov     rcx, hStdOut
    mov     rdx, offset sName
    mov     r8, sizeof sName
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 0ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    mov     ecx, dword ptr [rbx + 10h]  ; base
    mov     [rbp - 10h], ecx
    
    ; NumberOfFunctions
    mov     rcx, hStdOut
    mov     rdx, offset sNumberOfFunctions
    mov     r8, sizeof sNumberOfFunctions
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 14h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    
    ; NumberOfNames
    mov     rcx, hStdOut
    mov     rdx, offset sNumberOfNames
    mov     r8, sizeof sNumberOfNames
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 18h]
    mov     [rbp - 0ch], ecx               
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; AddressOfFunctions
    mov     rcx, hStdOut
    mov     rdx, offset sAddressOfFunctions
    mov     r8, sizeof sAddressOfFunctions
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 1ch]
    mov     edx, ecx
    mov     rcx, [rbp - 18h]
    mov     r8, [rbp - 8]
    call    rvatooffset
    add     rax, lpFileData
    mov     [rbp - 28h], rax
    mov     ecx, dword ptr [rbx + 1ch]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; AddressOfNames
    mov     rcx, hStdOut
    mov     rdx, offset sAddressOfNames
    mov     r8, sizeof sAddressOfNames
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 20h]
    mov     edx, ecx
    mov     rcx, [rbp - 18h]
    mov     r8, [rbp - 8]
    call    rvatooffset
    add     rax, lpFileData
    mov     [rbp - 30h], rax
    mov     ecx, dword ptr [rbx + 20h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; AddressOfNameOrdinals
    mov     rcx, hStdOut
    mov     rdx, offset sAddressOfNameOrdinals
    mov     r8, sizeof sAddressOfNameOrdinals
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx + 24h]
    mov     edx, ecx
    mov     rcx, [rbp - 18h]
    mov     r8, [rbp - 8]
    call    rvatooffset
    add     rax, lpFileData
    mov     [rbp - 38h], rax
    mov     ecx, dword ptr [rbx + 24h]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; Functions list
    nextExport:
    mov     ecx, dword ptr [rbp - 0ch]      ; NumberOfNames
    test    ecx, ecx    
    jz      _IMAGE_IMPORT_DESCRIPTOR
    ; FunctionRVA
    mov     rcx, hStdOut
    mov     rdx, offset sFunction
    mov     r8, sizeof sFunction
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     rax, [rbp - 38h]        ; rax = &AddressOfNameOrdinals
    movzx   ecx, word ptr [rax]
    mov     [rbp - 14h], ecx        ; save
    shl     ecx, 2
    add     rcx, [rbp - 28h]        ; + &AddressOfFunctions
    mov     ecx, dword ptr [rcx]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     byte ptr [rdx + r8], 9
    inc     r8
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; NameOrdinal
    mov     rcx, hStdOut
    mov     rdx, offset sNameOrdinal
    mov     r8, sizeof sNameOrdinal
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, [rbp - 14h]
    add     ecx, [rbp - 10h]            ; base
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     byte ptr [rdx + r8], 9
    inc     r8
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; Name
    mov     rcx, hStdOut
    mov     rdx, offset sName
    mov     r8, sizeof sName
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     rdx, [rbp - 30h]            ; address of names
    mov     edx, dword ptr [rdx]
    mov     rcx, [rbp - 18h]            
    mov     r8, [rbp - 8h]
    call    rvatooffset
    add     rax, lpFileData
    mov     rcx, rax
    mov     rdx, rcx
    call    strlencalc
    mov     r8, rax
    mov     rcx, hStdOut
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     word ptr [hexString], 0d0ah
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile           ; write linefeed

    mov     ecx, [rbp - 0ch]
    dec     ecx                 ; --NumberOfNames
    mov     [rbp - 0ch], ecx
    mov     rcx, [rbp - 30h]
    add     rcx, 4              ; AddressOfNames += 4
    mov     [rbp - 30h], rcx
    mov     rcx, [rbp - 38h]
    add     rcx, 2              ; addressOfNameOrdinals += 2
    mov     [rbp - 38h], rcx
    jmp     nextExport


    _IMAGE_IMPORT_DESCRIPTOR:
    mov     rcx, hStdOut
    mov     rdx, offset sImportDirectory
    mov     r8, sizeof sImportDirectory
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; get import offset
    mov     rcx, [rbp - 18h]
    mov     edx, dword ptr [rbp - 20h]
    mov     r8, [rbp - 8]
    call    rvatooffset             ; import rva -> offset
    mov     rbx, lpFileData
    add     rbx, rax
    mov     [rbp - 30h], rbx

    nextImport:
    mov     rbx, [rbp - 30h]
    mov     eax, dword ptr [rbx]
    xor     eax, dword ptr [rbx + 10h]  
    test    eax, eax
    jz      finished                ; if OriginalFirstThunk == 0 || FirstThunk == 0 no import left
    
    ; DllName
    mov     rcx, hStdOut
    mov     rdx, offset sDllName
    mov     r8, sizeof sDllName
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     rcx, qword ptr [rbp - 18h]
    mov     edx, dword ptr [rbx + 0ch]  
    mov     r8, [rbp - 8]
    call    rvatooffset
    add     rax, lpFileData         
    mov     rcx, rax
    mov     rdx, rcx
    call    strlencalc
    mov     r8, rax
    mov     rcx, hStdOut
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     word ptr [hexString], 0d0ah
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    mov     r8, [rbp - 8h]
    mov     rcx, [rbp - 18h]
    cmp     dword ptr [rbx], 0
    jz      byFirstThunk
    mov     edx, dword ptr [rbx]
    jmp     offsetcalc
    
    byFirstThunk:
    mov     edx, dword ptr [rbx + 10h]
    
    offsetcalc:
    call    rvatooffset             ; take OriginalFirstThunk or FirstThunk (if the first is unvalid) to calc offset
    add     rax, lpFileData
    mov     [rbp - 28h], rax        
    
    ; function list
    listFunction:
    mov     rbx, [rbp - 28h]
    cmp     dword ptr [rbx], 0      
    jne     nextFunction
    mov     rbx, [rbp - 30h]
    add     rbx, 14h                ; move rbx to next import_descriptor
    mov     [rbp - 30h], rbx
    jmp     nextImport

    nextFunction:
    mov     rbx, [rbp - 28h]
    test    dword ptr [rbx], 80000000h
    jnz     byOrdinal
    ; import by name
    mov     rcx, [rbp - 18h]
    mov     r8, [rbp - 8]
    mov     edx, dword ptr [rbx]
    call    rvatooffset
    mov     rbx, rax
    add     rbx, lpFileData

    _IMAGE_IMPORT_BY_NAME:
    ; Hint
    mov     rcx, hStdOut
    mov     rdx, offset sHint
    mov     r8, sizeof sHint
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    movzx   ecx, word ptr [rbx]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     byte ptr [rdx + r8], 9
    inc     r8
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    ; Name
    mov     rcx, hStdOut
    mov     rdx, offset sName
    mov     r8, sizeof sName
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    lea     rcx, [rbx + 2]      
    mov     rdx, rcx
    call    strlencalc
    mov     r8, rax
    mov     rcx, hStdOut
    call    WriteFile
    mov     word ptr [hexString], 0d0ah
    mov     rdx, offset hexString
    mov     rcx, hStdOut
    mov     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    jmp     continueFunction

    byOrdinal:
    mov     rbx, [rbp - 28h]
    ; Ordinal
    mov     rcx, hStdOut
    mov     rdx, offset sOrdinal
    mov     r8, sizeof sOrdinal
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile
    mov     ecx, dword ptr [rbx]
    mov     rdx, offset hexString
    call    ltoh
    mov     r8, rax
    mov     rcx, hStdOut
    mov     rdx, offset hexString
    mov     word ptr [rdx + r8], 0d0ah
    add     r8, 2
    mov     r9, offset nByte
    mov     [rsp + 20h], r12
    call    WriteFile

    continueFunction:
    mov     rbx, [rbp - 28h]
    add     rbx, 4
    cmp     isPE32, 1
    jz      continueNextFunction
    add     rbx, 4
    continueNextFunction:
    mov     [rbp - 28h], rbx
    jmp     listFunction


    finished:                       ; done parsing
    call    GetProcessHeap
    mov     rcx, rax
    mov     rdx, 1
    mov     r8, lpFileData
    call    HeapFree                ; free memory allocated before
    mov     ecx, 0
    call    ExitProcess

    errorExit:
    mov     rcx, hStdOut
    mov     rdx, offset sErrorOutput
    mov     r8, sizeof sErrorOutput
    mov     r9, offset nByte
    mov     [rsp + 20h], r12        
    call    WriteFile               ; output error msg on console
    mov     ecx, -1
    call    ExitProcess             ; then exit
main endp

strlencalc proc     ; calculate strlen(&rcx), return in rax
    push    rbp
    mov     rbp, rsp
    mov     rax, 0
    
    iter:
    cmp     byte ptr [rcx], 0
    jz      finished
    inc     rcx
    inc     rax
    jmp     iter
    
    finished:
    mov     rsp, rbp
    pop     rbp
    ret
strlencalc endp

ltoh proc   ; ltoh([in] val, [out] hexString) convert int64 to hex string return szArr in rax
    push    rbp    
    mov     rbp, rsp
    push    rdi
    mov     rax, rcx
    mov     rdi, rdx            
    mov     r10, rdi            ; save rdi
    mov     r8, 16
    push    "#"                 ; pivot
    getDigit:
    xor     rdx, rdx
    div     r8
    cmp     edx, 0Ah
    jl      xor30
    add     edx, 37h            ; if a - f -> "a"-"f"
    jmp     saveDigit
    
    xor30:
    xor     edx, 30h            ; if 0 - 9 -> "0" - "9"
    saveDigit:
    push    dx
    test    rax, rax
    jz      toString
    jmp     getDigit

    toString:                   ; get char from stack to hexString
    pop     ax
    cmp     ax, "#"
    jz      done
    stosb
    jmp     toString

    done:
    sub     rdi, r10
    mov     rax, rdi
    pop     rdi
    mov     rsp, rbp
    pop     rbp
    ret   
ltoh endp

rvatooffset proc    ; rvatooffset(NumberOfSections, RVA, &SectionHeader) return offset in rax
    push    rbp
    mov     rbp, rsp
    push    rbx
    mov     rbx, r8

    iter:
    test    cx, cx              ; sizeof NumberOfSections = word
    jz      finished
    mov     eax, dword ptr [rbx + 0ch]
    cmp     edx, eax            ; if RVA < currentSection VirtualAddress
    jl      nextSection         ; -> next
    add     eax, dword ptr [rbx + 8]    ; eax = va + virtualSize
    cmp     edx, eax            ; if RVA >= SectionHeader + VirtualSize
    jge     nextSection         ; -> next
    mov     eax, dword ptr [rbx + 0ch]  ; eax = va
    sub     edx, eax            
    mov     eax, dword ptr [rbx + 14h]  ; pointerToRawData
    add     eax, edx
    jmp     finished

    nextSection:
    add     rbx, 28h            ; next section
    dec     cx
    jmp     iter
    mov     eax, edx

    finished:
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret
rvatooffset endp
end
extrn   CreateWindowExA:    proc
extrn   DefWindowProcA:     proc
extrn   DispatchMessageA:   proc
extrn   ExitProcess:        proc
extrn   LoadIconA:          proc
extrn   LoadCursorA:        proc
extrn   GetDlgItemTextA:    proc
extrn   GetCommandLineA:    proc
extrn   GetMessageA:        proc
extrn   GetModuleHandleA:   proc
extrn   PostQuitMessage:    proc
extrn   RegisterClassExA:   proc
extrn   SetDlgItemTextA:    proc
extrn   ShowWindow:         proc
extrn   TranslateMessage:   proc

.data
    szClassName         db  "TextReverse", 0
    lpMainWindowName    db  "Text Reverse", 0
    lpClassNameEdit     db  "EDIT", 0
    lpClassNameStatic   db  "STATIC", 0
    lpWindowNameInput    db  "Input string:", 0
    lpWindowNameOutput   db  "Reversed string:", 0
.data?
    wndclass    db  80  dup(?)      ; struct WNDCLASSEXA
    msg         db  48  dup(?)      ; struct MSG
    hwnd        dq  ?    
    buffer      db  255 dup(?)
.code
WinMainCRTStartup proc
    mov     rbp, rsp
    sub     rsp, 28h

    xor     rcx, rcx
    call    GetModuleHandleA
    mov     rcx, rax
    call    GetCommandLineA
    mov     r8, rax
    mov     r9, 10
    xor     rdx, rdx
    call    WinMain

    mov     rsp, rbp
    pop     rbp
    ret
WinMainCRTStartup endp

WinMain proc
    push    rbp
    mov     rbp, rsp
    sub     rsp, 60h        

    mov     r12, rcx                            ; hInstance
    mov     qword ptr [wndclass + 18h], rcx     ; ->hInstance
    mov     dword ptr [wndclass], 80            ; ->cbSize = sizeof WNDCLASSEXA
    mov     dword ptr [wndclass + 4], 2 or 1    ; ->style = CS_HREDRAW | CS_VREDRAW
    mov     rcx, offset WinProc
    mov     qword ptr [wndclass + 8], rcx       ; ->lpfnWndProc = WinProc    
    mov     dword ptr [wndclass + 10h], 0       ; ->cbClsExtra = 0
    mov     dword ptr [wndclass + 14h], 0       ; ->cbWndExtra = 0
    xor     ecx, ecx
    mov     edx, 32512                          ; IDI_APPLICATION aka standard icon ids
    call    LoadIconA
    mov     qword ptr [wndclass + 20h], rax     ; -> hIcon = LoadIconA(NULL, IDI_APPLICATION)
    xor     ecx, ecx
    mov     edx, 32512                          ; IDC_ARROW aka standard cursor ids
    call    LoadCursorA
    mov     qword ptr [wndclass + 28h], rax     ; ->hCursor = 
    mov     qword ptr [wndclass + 30h], 1       ; ->hbrBackgrount = COLOR_BACKGROUND
    mov     qword ptr [wndclass + 38h], 0       ; -> lpszMenuName = null
    mov     rcx, offset szClassName
    mov     qword ptr [wndclass + 40h], rcx     ; -> lpszClassName = "TextReverse"
    mov     rcx, qword ptr [wndclass + 20h]
    mov     qword ptr [wndclass + 48h], rcx     ; -> hIconSm = LoadIconA(NULL, IDI_APPLICATION)

    ; try registering class
    lea     rcx, wndclass
    call    RegisterClassExA
    test    ax, ax
    jz      exitProgram

    ; once registered succeedfully create program...
    mov     dword ptr [rsp + 20h], 80000000h    ; CW_USEDEFAULT
    mov     dword ptr [rsp + 28h], 80000000h    ; CW_USEDEFAULT
    mov     qword ptr [rsp + 30h], 500          ; program's width
    mov     qword ptr [rsp + 38h], 130          ; program's height
    mov     qword ptr [rsp + 40h], 0            ; HWND_DESKTOP -> child window to desktop
    mov     qword ptr [rsp + 48h], 0            ; no menu
    mov     qword ptr [rsp + 50h], r12          ; hInstance
    mov     qword ptr [rsp + 58h], 0            ; no win creation data
    xor     rcx, rcx
    lea     rdx, szClassName     
    lea     r8, lpMainWindowName                ; title text
    mov     r9, 0cf0000h                        ; WS_OVERLAPPEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX
    call    CreateWindowExA                     ; CreateWindowExA(0, szClassName, szClassName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 300, 150, HWND_DESKTOP, NULL, hInstance, NULL)
    mov     hwnd, rax

    ; make the window visible on screen
    mov     rcx, rax
    mov     rdx, 1                              ; SW_NORMAL
    call    ShowWindow

    ; run msg loop
    gettingMessage:
    lea     rcx, msg
    xor     rdx, rdx
    xor     r8, r8
    xor     r9, r9
    call    GetMessageA
    test    rax, rax        ; if returns 0
    jz      exitProgram     ; in fact it is return msg.wParam but it always is 0 (= PostQuitMessage() return value)

    ; translate virtual key msg into character msg
    lea     rcx, msg
    call    TranslateMessage    

    ; send to WinProc
    lea     rcx, msg
    call    DispatchMessageA
    jmp     gettingMessage  ; loop

    exitProgram:
    mov     rcx, rax
    call    ExitProcess
WinMain endp

WinProc proc
    push    rbp
    mov     rbp, rsp
    sub     rsp, 70h
    mov     [rbp + 10h], rcx    ; hwnd
    mov     [rbp + 18h], rdx    ; msg
    mov     [rbp + 20h], r8     ; wParam
    mov     [rbp + 28h], r9     ; lParam
    mov     rax, rdx        ; msg

    ; implement switch-case
    dec     rax
    jz      WM_CREATE       ; WM_CREATE = 1
    dec     rax
    jz      WM_DESTROY      ; WM_DESTROY = 2
    sub     rax, 10fh       
    jz      WM_COMMAND      ; WM_COMMAND = 0x0111
    ; for other messages
    mov     rcx, [rbp + 10h]
    mov     rdx, [rbp + 18h]
    mov     r8, [rbp + 20h]
    mov     r9, [rbp + 28h]
    call    DefWindowProcA  ; DefWindowProcA(hwnd, message, wParam, lParam)
    jmp     exitProc

    WM_CREATE:
    ; first editbox and label
    mov     qword ptr [rsp + 20h], 10   ; x = 10 from mainwindow
    mov     qword ptr [rsp + 28h], 10   ; y = 10 from mainwindow
    mov     qword ptr [rsp + 30h], 150  ; width = 250
    mov     qword ptr [rsp + 38h], 30   ; height = 30
    mov     rax, [rbp + 10h]            ; hwnd
    mov     qword ptr [rsp + 40h], rax
    mov     qword ptr [rsp + 48h], 11   ; set hMenu = 1
    mov     qword ptr [rsp + 50h], 0
    mov     qword ptr [rsp + 58h], 0
    xor     rcx, rcx
    lea     rdx, lpClassNameStatic
    lea     r8, lpWindowNameInput
    mov     r9, 50000000h  ; WS_CHILD | WS_VISIBLE
    call    CreateWindowExA

    mov     qword ptr [rsp + 20h], 200  ; x = 10 from mainwindow
    mov     qword ptr [rsp + 28h], 10   ; y = 10 from mainwindow
    mov     qword ptr [rsp + 30h], 250  ; width = 250
    mov     qword ptr [rsp + 38h], 30   ; height = 30
    mov     rax, [rbp + 10h]            ; hwnd
    mov     qword ptr [rsp + 40h], rax
    mov     qword ptr [rsp + 48h], 1    ; set hMenu = 1
    mov     qword ptr [rsp + 50h], 0
    mov     qword ptr [rsp + 58h], 0
    xor     rcx, rcx
    lea     rdx, lpClassNameEdit
    xor     r8, r8
    mov     r9, 1350565888  ; WS_BORDER | WS_CHILD | WS_VISIBLE
    call    CreateWindowExA

    ; second editbox and label
    mov     qword ptr [rsp + 20h], 10   ; x = 10 from mainwindow
    mov     qword ptr [rsp + 28h], 50   ; y = 10 from mainwindow
    mov     qword ptr [rsp + 30h], 150  ; width = 250
    mov     qword ptr [rsp + 38h], 30   ; height = 30
    mov     rax, [rbp + 10h]            ; hwnd
    mov     qword ptr [rsp + 40h], rax
    mov     qword ptr [rsp + 48h], 12   ; set hMenu = 1
    mov     qword ptr [rsp + 50h], 0
    mov     qword ptr [rsp + 58h], 0
    xor     rcx, rcx
    lea     rdx, lpClassNameStatic
    lea     r8, lpWindowNameOutput
    mov     r9, 50000000h  ; WS_CHILD | WS_VISIBLE
    call    CreateWindowExA

    mov     qword ptr [rsp + 20h], 200  ; x = 10 from mainwindow
    mov     qword ptr [rsp + 28h], 50   ; y = 50 from mainwindow
    mov     qword ptr [rsp + 30h], 250  ; width = 250
    mov     qword ptr [rsp + 38h], 30   ; height = 30
    mov     rax, [rbp + 10h]            ; hwnd
    mov     qword ptr [rsp + 40h], rax
    mov     qword ptr [rsp + 48h], 2    ; set hMenu = 2
    mov     qword ptr [rsp + 50h], 0
    mov     qword ptr [rsp + 58h], 0
    xor     rcx, rcx
    lea     rdx, lpClassNameEdit
    xor     r8, r8
    mov     r9, 1350567936              ; WS_VISIBLE | WS_CHILD | WS_BORDER | ES_READONLY
    call    CreateWindowExA
    jmp     exitProc

    WM_DESTROY:
    xor     rcx, rcx
    call    PostQuitMessage
    jmp     exitProc

    WM_COMMAND:
    mov     rax, [rbp + 20h]
    sub     ax, 1       ; if hMenu = 1
    jz      editBox1
    jmp     exitProc

    editBox1:
    mov     rcx, [rbp + 10h]
    mov     rdx, 1  
    lea     r8, buffer
    mov     r9, 255
    call    GetDlgItemTextA     ; GetDlgItemTextA(hwnd, 1, &buffer, 255) to get text input
    lea     rcx, buffer
    call    reverse
    mov     rcx, [rbp + 10h]
    mov     rdx, 2
    lea     r8, buffer
    call    SetDlgItemTextA

    exitProc:
    mov     rsp, rbp
    pop     rbp
    ret
WinProc endp

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
    cmp     al, 0           ; check for 0 = end of data
    jz      startPop
    push    ax              ; push 16bit
    inc     cx
    jmp     iterPush

    startPop:
    sub     rsi, rdi
    iterPop:                ; pop back
    test    cx, cx
    jz      done
    pop     ax
    dec     cx
    stosb                   ; byte ptr [rdi]-- = al
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
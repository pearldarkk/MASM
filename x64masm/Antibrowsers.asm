extrn   CloseHandle:                proc
extrn   CreateWindowExA:            proc
extrn   DefWindowProcA:             proc
extrn   DispatchMessageA:           proc
extrn   EnumWindows:                proc
extrn   ExitProcess:                proc
extrn   KillTimer:                  proc
extrn   LoadIconA:                  proc
extrn   LoadCursorA:                proc
extrn   GetDlgItemTextA:            proc
extrn   GetCommandLineA:            proc
extrn   GetMessageA:                proc
extrn   GetModuleHandleA:           proc
extrn   GetWindowThreadProcessId:   proc
extrn   GetProcessImageFileNameA:   proc
extrn   OpenProcess:                proc
extrn   PostQuitMessage:            proc
extrn   RegisterClassExA:           proc
extrn   SendMessageA:               proc
extrn   SetDlgItemTextA:            proc
extrn   SetTimer:                   proc
extrn   ShowWindow:                 proc
extrn   TranslateMessage:           proc

.data
    szClassName         db  "AntiBrowsers", 0
    lpMainWindowName    db  "Anti-browsers", 0
    lpClassNameStatic   db  "STATIC", 0
    lpWindowNameText    db  "No browsers allowed while I'm running!", 0
    firefoxExeName      db  "firefox.exe", 0
    chromeExeName       db  "chrome.exe", 0
    msedgeExeName       db  "msedge.exe", 0
.data?
    wc          db  80  dup(?)      
    msg         db  48  dup(?)      
    hwnd        dq  ?    
    buffer      db  255 dup(?)
    procId      dd  ?
    len         dd  ?
    hProc       dq  ?
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
    mov     [rbp + 10h], rcx
    mov     [rbp + 18h], rdx

    mov     qword ptr [wc + 18h], rcx       ; ->hInstance
    mov     dword ptr [wc], 80              ; ->cbSize = sizeof WNDCLASSEXA
    mov     dword ptr [wc + 4], 2 or 1      ; ->style = CS_HREDRAW | CS_VREDRAW
    lea     rcx, WinProc
    mov     qword ptr [wc + 8], rcx         ; ->lpfnWndProc = WinProc    
    mov     dword ptr [wc + 10h], 0         ; ->cbClsExtra = 0
    mov     dword ptr [wc + 14h], 0         ; ->cbWndExtra = 0
    xor     ecx, ecx
    mov     edx, 32512                      ; IDI_APPLICATION aka standard icon ids
    call    LoadIconA
    mov     qword ptr [wc + 20h], rax       ; -> hIcon = LoadIconA(NULL, IDI_APPLICATION)
    xor     ecx, ecx
    mov     edx, 32512                      ; IDC_ARROW aka standard cursor ids
    call    LoadCursorA
    mov     qword ptr [wc + 28h], rax       ; ->hCursor = 
    mov     qword ptr [wc + 30h], 1         ; ->hbrBackgrount = COLOR_BACKGROUND
    mov     qword ptr [wc + 38h], 0         ; -> lpszMenuName = null
    mov     rcx, offset szClassName
    mov     qword ptr [wc + 40h], rcx       ; -> lpszClassName = "TextReverse"
    mov     rcx, qword ptr [wc + 20h]
    mov     qword ptr [wc + 48h], rcx       ; -> hIconSm = LoadIconA(NULL, IDI_APPLICATION)

    ; try registering class
    lea     rcx, wc
    call    RegisterClassExA
    test    ax, ax
    jz      exitProgram

    ; once registered succeedfully create program...
    mov     dword ptr [rsp + 20h], 80000000h    ; CW_USEDEFAULT
    mov     dword ptr [rsp + 28h], 80000000h    ; CW_USEDEFAULT
    mov     qword ptr [rsp + 30h], 330          ; program's width
    mov     qword ptr [rsp + 38h], 100          ; program's height
    mov     qword ptr [rsp + 40h], 0            ; HWND_DESKTOP -> child window to desktop
    mov     qword ptr [rsp + 48h], 0            ; no menu
    mov     rcx, [rbp + 10h]
    mov     qword ptr [rsp + 50h], rcx          ; hInstance
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
    sub     rax, 111h       
    jz      WM_TIMER        ; WM_TIMER = 113h
    ; for other messages
    mov     rcx, [rbp + 10h]
    mov     rdx, [rbp + 18h]
    mov     r8, [rbp + 20h]
    mov     r9, [rbp + 28h]
    call    DefWindowProcA  ; DefWindowProcA(hwnd, message, wParam, lParam)
    jmp     exitProc

    WM_CREATE:
    ; a string pop-up
    mov     qword ptr [rsp + 20h], 20   ; x = 10 from mainwindow
    mov     qword ptr [rsp + 28h], 20   ; y = 10 from mainwindow
    mov     qword ptr [rsp + 30h], 270  ; width = 250
    mov     qword ptr [rsp + 38h], 20   ; height = 30
    mov     rax, [rbp + 10h]            ; hwnd
    mov     qword ptr [rsp + 40h], rax
    mov     qword ptr [rsp + 48h], 1    ; set hMenu = 1
    mov     qword ptr [rsp + 50h], 0
    mov     qword ptr [rsp + 58h], 0
    xor     rcx, rcx
    lea     rdx, lpClassNameStatic
    lea     r8, lpWindowNameText
    mov     r9, 50000000h  ; WS_CHILD | WS_VISIBLE
    call    CreateWindowExA

    lea     rcx, nextWindow
    mov     rdx, 0
    call    EnumWindows
    mov     rcx, [rbp + 10h]    ; hwnd
    mov     rdx, 1
    mov     r8, 5000
    xor     r9, r9
    call    SetTimer            ; set a timer every 5 seconds
    jmp     exitProc

    WM_DESTROY:
    mov     rcx, [rbp + 10h]
    mov     rdx, 1
    call    KillTimer           ; kill timer and request to quit
    xor     rcx, rcx
    call    PostQuitMessage
    jmp     exitProc

    WM_TIMER:
    lea     rcx, nextWindow
    xor     rdx, rdx
    call    EnumWindows         ; enum each 5 seconds

    exitProc:
    mov     rsp, rbp
    pop     rbp
    ret
WinProc endp

nextWindow proc
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 20h
    mov     [rbp + 10h], rcx    ; hwnd
    mov     [rbp + 18h], rdx    ; lParam

    test    rcx, rcx
    jz      exitProc

    lea     rdx, procId
    call    GetWindowThreadProcessId    ; get hProc from hwnd
    mov     ecx, 400h
    xor     edx, edx
    mov     r8d, procId
    call    OpenProcess                 ; open process to retrieve information
    mov     hProc, rax
    mov     rcx, hProc
    lea     rdx, buffer
    mov     r8d, 255
    call    GetProcessImageFileNameA    ; get process executable file name (full path)
    ; take the executable filename only
    ; find len of filename
    lea     rcx, buffer
    call    strlen
    lea     rsi, buffer
    add     rsi, rax
    std                                 ; set DF
    iterBuffer:
    lodsb
    cmp     al, '\'
    jz      cmpBrowsers
    jmp     iterBuffer

    cmpBrowsers:
    lea     rax, buffer
    sub     rsi, rax
    mov     rax, rsi
    add     rax, 2
    mov     rbx, rax

    ; cmp with firefox.exe
    lea     rcx, buffer
    add     rcx, rbx
    lea     rdx, firefoxExeName
    mov     r8, 12
    call    strncmp
    test    rax, rax
    jz      destroyWindow

    ; cmp with chrome.exe
    lea     rcx, buffer
    add     rcx, rbx
    lea     rdx, chromeExeName
    mov     r8, 11
    call    strncmp
    test    rax, rax
    jz      destroyWindow

    ; cmp with msedge.exe
    lea     rcx, buffer
    add     rcx, rbx
    lea     rdx, msedgeExeName
    mov     r8, 11
    call    strncmp
    test    rax, rax
    jz      destroyWindow
    jmp     exitProc

    destroyWindow:
    mov     rcx, [rbp + 10h]
    mov     rdx, 2          ; WM_DESTROY
    xor     r8, r8
    xor     r9, r9
    call    SendMessageA

    exitProc:
    mov     rcx, hProc
    call    CloseHandle     ; close process handle
    mov     rax, 1
    add     rsp, 20h
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret
nextWindow endp

strlen proc     ; strlen(&buf) work similar to strlen() in C
    push    rbp
    mov     rbp, rsp
    push    rsi
    mov     rsi, rcx
    cld

    iter:
    lodsb
    test    al, al
    jz      exit
    jmp     iter

    exit:
    sub     rsi, rcx
    mov     rax, rsi
    dec     rax
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret
strlen endp

strncmp proc            ; work similar to strncmp() in C
    push    rbp
    mov     rbp, rsp
    push    rsi
    push    rdi
    mov     rsi, rcx
    mov     rdi, rdx

    cld
    mov     rcx, r8
    iter:
    lodsb
    mov     dl, byte ptr [rdi]
    cmp     al, dl
    jnz     exit
    inc     rdi
    dec     cx
    jnz     iter

    equal:
    mov     rax, 0
    pop     rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret

    exit:
    mov     rax, rcx
    pop     rdi
    pop     rsi
    mov     rsp, rbp
    pop     rbp
    ret
strncmp endp
end
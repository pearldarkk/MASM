extrn   CreateSolidBrush:   proc
extrn   CreateWindowExA:    proc
extrn   DefWindowProcA:     proc
extrn   DispatchMessageA:   proc
extrn   Ellipse:            proc
extrn   ExitProcess:        proc
extrn   FillRect:           proc
extrn   LoadIconA:          proc
extrn   LoadCursorA:        proc
extrn   KillTimer:          proc
extrn   GetClientRect:      proc
extrn   GetCommandLineA:    proc
extrn   GetDC:              proc
extrn   GetLocalTime:       proc
extrn   GetMessageA:        proc
extrn   GetModuleHandleA:   proc
extrn   GetStockObject:     proc
extrn   PostQuitMessage:    proc
extrn   RegisterClassExA:   proc
extrn   ReleaseDC:          proc
extrn   SelectObject:       proc
extrn   SetTimer:           proc
extrn   ShowWindow:         proc
extrn   TranslateMessage:   proc

.data
    szClassName         db  "BoucingBall", 0
    lpMainWindowName    db  "Boucing Ball", 0
.data?
    wndclass    db  80  dup(?)      ; struct WNDCLASSEXA
    msg         db  48  dup(?)      ; struct MSG
    hdc         dq  ?               ; HDC
    hwnd        dq  ?    
    lpTime      db  16  dup(?)      ; struct SYSTEMTIME
    rect        db  16  dup(?)      ; struct RECT
    tmpRect     db  16  dup(?)      ; struct RECT
    hWhiteBrush dq  ?
    hRedBrush   dq  ?
    ; direction of the ball
    xDir        dd  ?
    yDir        dd  ?
    ; current position of the ball
    x           dd  ?
    y           dd  ?
    ; old position of the ball
    xOld        dd  ?
    yOld        dd  ?
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
    lea     rcx, WinProc
    mov     qword ptr [wndclass + 8], rcx       ; ->lpfnWndProc = WinProc    
    mov     dword ptr [wndclass + 10h], 0       ; ->cbClsExtra = 0
    mov     dword ptr [wndclass + 14h], 0       ; ->cbWndExtra = 0
    xor     ecx, ecx
    mov     edx, 32512                          ; IDI_APPLICATION aka standard icon ids
    call    LoadIconA
    mov     qword ptr [wndclass + 20h], rax               ; -> hIcon = LoadIconA(NULL, IDI_APPLICATION)
    mov     qword ptr [wndclass + 48h], rax     ; -> hIconSm = LoadIconA(NULL, IDI_APPLICATION)
    xor     ecx, ecx
    mov     edx, 32512                          ; IDC_ARROW aka standard cursor ids
    call    LoadCursorA
    mov     qword ptr [wndclass + 28h], rax               ; ->hCursor = LoadCursorA(NULL, IDI_APPLICATION)
    mov     ecx, 0ffh    
    call    CreateSolidBrush
    mov     hRedBrush, rax
    xor     ecx, ecx
    call    GetStockObject                      
    mov     hWhiteBrush, rax
    mov     qword ptr [wndclass + 30h], rax     ; ->hbrBackgrount = GetStockObject(WHITE_BRUSH);
    mov     qword ptr [wndclass + 38h], 0       ; -> lpszMenuName = null
    lea     rcx, szClassName
    mov     qword ptr [wndclass + 40h], rcx     ; -> lpszClassName = "TextReverse"

    ; try registering class
    lea     rcx, wndclass
    call    RegisterClassExA
    test    ax, ax
    jz      exitProgram

    ; once registered succeedfully create program...
    mov     dword ptr [rsp + 20h], 80000000h    ; CW_USEDEFAULT
    mov     dword ptr [rsp + 28h], 80000000h    ; CW_USEDEFAULT
    mov     qword ptr [rsp + 30h], 400          ; program's width
    mov     qword ptr [rsp + 38h], 300          ; program's height
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
    push    rbx
    sub     rsp, 38h
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
    jz      WM_TIMER        ; WM_COMMAND = 113h
    sub     rax, 101h       
    jz      WM_SIZING       ; WM_SIZING = 214h
    ; for other messages
    mov     rcx, [rbp + 10h]
    mov     rdx, [rbp + 18h]
    mov     r8, [rbp + 20h]
    mov     r9, [rbp + 28h]
    call    DefWindowProcA  ; DefWindowProcA(hwnd, message, wParam, lParam)
    jmp     exitProc

    WM_CREATE:
    ; Randomize direction based on last 2 bits of second value (from local time)
    lea     rcx, lpTime
    call    GetLocalTime
    mov     bx, word ptr [lpTime + 0ch]  ; lpTime->wSecond
    and     bx, 3               ; clear out and save only last 2 bits (so that result only have 4 possible values)
    jz      rightUp             ; bl == 0
    dec     bl
    jz      leftUp              ; bl == 1
    dec     bl                  
    jz      rightDown           ; bl == 2
    jmp     leftDown            ; bl == 3
    ; set direction
    rightUp:
    mov     xDir, 5
    mov     yDir, 5
    jmp     setLocation

    leftUp:
    mov     xDir, -5
    mov     yDir, 5
    jmp     setLocation

    rightDown:
    mov     xDir, 5
    mov     yDir, -5
    jmp     setLocation

    leftDown:
    mov     xDir, -5
    mov     yDir, -5

    setLocation:                ; set the ball at middle of window
    mov     rcx, [rbp + 10h]
    lea     rdx, rect
    call    GetClientRect
    mov     eax, dword ptr [rect + 8]     ; rect->right
    shr     eax, 1              ; >> 1 (equal /2)
    sub     eax, 10             ; rBall = 10
    mov     x, eax
    mov     eax, dword ptr [rect + 0ch]   ; rect->bottom
    shr     eax, 1              ; >> 1 (equal /2)
    sub     eax, 10             ; rBall = 10
    mov     y, eax

    ; create timer
    mov     rcx, qword ptr [rbp + 10h]    ; hwnd
    mov     edx, 1
    mov     r8d, 17             ; every 0.017 seconds
    xor     r9, r9
    call    SetTimer            ; SetTimer(hwnd, 1, 14, NULL)
    jmp     exitProc

    WM_DESTROY:
    mov     rcx, [rbp + 10h]
    mov     edx, 1
    call    KillTimer
    xor     rcx, rcx
    call    PostQuitMessage
    jmp     exitProc

    WM_TIMER:
    mov     rcx, [rbp + 10h]
    call    GetDC
    mov     hdc, rax
    mov     rcx, hdc
    mov     rdx, hWhiteBrush
    call    SelectObject
    mov     rbx, rax

    ; fill in tmpRect old position of the ball
    mov     eax, xOld   
    mov     dword ptr [tmpRect], eax          ; temp.left = oldX;
    add     eax, 20                 
    mov     dword ptr [tmpRect + 8], eax      ; temp.right = oldX + 20;
    mov     eax, yOld               ; temp.top = oldY;
    mov     dword ptr [tmpRect + 4], eax
    add     eax, 20
    mov     dword ptr [tmpRect + 0ch], eax    ; temp.bottom = oldY + 20;
    mov     rcx, hdc
    lea     rdx, tmpRect
    mov     r8, rbx
    call    FillRect                ; erase the old ball 

    ; paint new ball
    mov     rcx, hdc
    mov     rdx, hRedBrush
    call    SelectObject
    mov     rcx, hdc
    mov     edx, x
    mov     r8d, y
    mov     r9d, x
    add     r9d, 20
    mov     eax, y
    add     eax, 20
    mov     [rsp + 20h], eax        ; ; Ellipse(hdc, x, y, 20 + x, 20 + y);
    call    Ellipse
    mov     eax, x
    mov     xOld, eax
    mov     eax, y
    mov     yOld, eax
    
    ; prep new coordinates for the ball 
    ; if the ball is going to go off the edges, reverse direction
    mov     ebx, -1
    mov     eax, x
    add     eax, xDir
    cmp     eax, 0                  ; if x + xDir < 0
    jl      reverseX
    add     eax, 20                 
    cmp     eax, dword ptr [rect + 8]         ; if x + xDir + 20 > rect.right
    jg      reverseX

    checkY:
    mov     eax, y
    add     eax, yDir
    cmp     eax, 0                  ; if y + yDir < 0
    jl      reverseY
    add     eax, 20                 
    cmp     eax, dword ptr [rect + 0ch]       ; if y + yDir + 20 > rect.bottom
    jg      reverseY
    jmp     updateCoordinates

    reverseX:
    mov     eax, xDir
    imul    ebx
    mov     xDir, eax
    jmp     checkY

    reverseY:
    mov     eax, yDir
    imul    ebx
    mov     yDir, eax

    ; update coordinates
    updateCoordinates:
    mov     eax, x
    add     eax, xDir
    mov     x, eax
    mov     eax, y
    add     eax, yDir
    mov     y, eax

    ; release DC
    mov     rcx, [rbp + 10h]
    mov     rdx, hdc
    call    ReleaseDC
    jmp     exitProc

    WM_SIZING:
    mov     rcx, [rbp + 10h]
    lea     rdx, rect
    call    GetClientRect
    ; if the ball is outside the window, put it back
    checkEdge:
    mov     eax, x
    cmp     eax, 0
    jl      putLeftEdge
    add     eax, 20
    cmp     eax, dword ptr [rect + 8]
    jg      putRightEdge
    mov     eax, y
    cmp     eax, 0
    jl      putTopEdge
    add     eax, 20
    cmp     eax, dword ptr [rect + 0ch]
    jg      putBottomEdge
    jmp     exitProc

    putLeftEdge:
    xor     eax, eax
    mov     x, eax
    jmp     checkEdge

    putRightEdge:
    mov     eax, dword ptr [rect + 8]
    sub     eax, 20
    mov     x, eax
    jmp     checkEdge

    putTopEdge:
    xor     eax, eax
    mov     y, eax
    jmp     checkEdge

    putBottomEdge:
    mov     eax, dword ptr [rect + 0ch]
    sub     eax, 20
    mov     x, eax
    jmp     checkEdge

    exitProc:
    add     rsp, 38h
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret
WinProc endp

end
.data
sProgramHeaderTable db  "Type", 9, "Offset", 9, "VirtAddr", 9, "PhysAddr", 9, "FileSiz", 9, "MemSiz", 9, "Flags", 9, "Align", 0ah, 0
.code
main proc
    mov     rax, sizeof sProgramHeaderTable
    mov     rbx, 0
main endp
end
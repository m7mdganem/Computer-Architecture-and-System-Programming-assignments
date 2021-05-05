section .bss
    evenCheckResult: resb 4

section .data
    format: db "%d",10,0                          ; 10 for newline -\n- and 0 for null terminating char -\0-

section .text
    extern c_checkValidity
    extern printf
    global assFunc

assFunc:
    push        ebp
    mov         ebp,esp
    mov         ebx,[ebp+8]
    pushad
    pushfd
    push        ebx
    call        c_checkValidity
    mov         [evenCheckResult],eax
    add         esp,4
    popfd
    popad
    cmp         dword [evenCheckResult],1
    jz          even
    sal         ebx,3
    jmp         end
    even:
        sal         ebx,2
    end:
        pushad
        pushfd
        push        ebx
        push        format
        call        printf
        add         esp,8
        popfd
        popad
        mov         esp,ebp
        pop         ebp
        ret

%macro check_for_debug 2
    mov eax, %1
    add eax, 4
    mov ebx, [eax]
    cmp byte [ebx], '-'
    jne %%check_second_argument 
    cmp byte [ebx+1], 'd'
    jne %%check_second_argument
    mov byte [debug], 1
    jmp %%end
    %%check_second_argument:
    cmp %2, 3
    jne %%end
    add eax, 4
    mov ebx, [eax]
    cmp byte [ebx], '-'
    jne %%end
    cmp byte [ebx+1], 'd'
    jne %%end
    mov byte [debug], 1
    %%end:
%endmacro

%macro my_malloc 2
    pushad
    push dword %2
    push dword %1
    call malloc
    add esp, 4
    pop ebx
    mov [ebx], eax
    popad
%endmacro

%macro my_calloc 2
    pushad
    push dword %2
    push dword 4
    push dword %1
    call calloc
    add esp, 8
    pop ebx
    mov [ebx], eax
    popad
%endmacro

%macro get_input 0
    pushad
    push dword [stdin]
    push dword 80
    push dword input_buffer
    call fgets
    add esp,12
    popad
%endmacro

%macro print_to_stdout 1
    pushad
    push %1
    push string_format
    call printf
    add esp, 8
    push dword [stdout]
    call fflush
    add esp, 4
    popad
%endmacro

%macro print 1
    pushad
    push %1
    push string_format
    push dword [stderr]
    call fprintf
    add esp, 12
    popad
%endmacro

%macro print_number 1
    pushad
    push %1
    push format
    push dword [stderr]
    call fprintf
    add esp, 12
    popad
%endmacro

%macro print_pointer 1
    pushad
    push %1
    push pointer_format
    push dword [stderr]
    call fprintf
    add esp, 12
    popad
%endmacro

%macro convert_4_bytes_to_hex 2
;*** assuming that ecx is clear (all its bits are zeroes)
;    this macro converts 4 bytes (each byte represents a bit)
;    to the hexadecimal representation and saves it to ecx. 
;    this macro gets 2 argument : 
;    1- the memory to read from
;    2- index to start reading from ***
    mov edx, %1
    mov ebx, %2
    xor eax, eax
    mov byte al, [ebx+edx]
    shl eax, 3
    or ecx, eax
    xor eax, eax
    mov byte al, [ebx+edx+1]
    shl eax, 2
    or ecx, eax
    xor eax, eax
    mov byte al, [ebx+edx+2]
    shl eax, 1
    or ecx, eax
    xor eax, eax
    mov byte al, [ebx+edx+3]
    or ecx, eax
    mov edx, 8
%endmacro

%macro convert_less_than_8_to_hex 2
    mov edx, %1
    mov ebx, %2
    push ebx
    %%bytes_loop:
    cmp ebx,0
    je %%end
    xor eax, eax
    mov byte al, [edx]
    mov esi, 1
    %%loop:
        cmp esi,ebx
        je %%end_loop
        shl byte al,1
        inc esi
        jmp %%loop
    %%end_loop:
    or ecx, eax
    dec ebx
    inc edx
    jmp %%bytes_loop
    %%end:
    pop ebx
%endmacro

; %macro convert_linked_list_to_binary_array 2
;     ;NOTE: this macro modifies the bytes saved in the linked list!!!
;     pushad
;     mov ebx, %1     ;the address to the linked list
;     mov ecx, %2     ;length of linked list
;     mov eax, 8
;     mul ecx
;     %%loop:
;     cmp ecx, 0
;     je %%end
;     mov esi, 0
;     %%byte_loop:
;         cmp esi,8
;         je %%end_byte_loop
;         dec eax
;         shr byte [ebx],1
;         jnc %%zero
;         mov byte [binary_buffer+eax], 1
;         inc esi
;         jmp %%byte_loop
;         %%zero:
;         mov byte [binary_buffer+eax], 0
;         inc esi
;         jmp %%byte_loop
;         %%end_byte_loop:
;         dec ecx
;         mov ebx, [ebx+1]
;         jmp %%loop
;     %%end:
;     popad
; %endmacro

%macro convert_linked_list_to_binary_array 2
    pushad
    mov ebx, %1     ;the address to the linked list
    mov ecx, %2     ;length of linked list
    mov eax, 8
    mul ecx
    %%loop:
    cmp ecx, 0
    je %%end
    mov esi, 0
    xor edx, edx
    mov byte dl, [ebx]
    %%byte_loop:
        cmp esi,8
        je %%end_byte_loop
        dec eax
        shr byte dl,1
        jnc %%zero
        mov byte [binary_buffer+eax], 1
        inc esi
        jmp %%byte_loop
        %%zero:
        mov byte [binary_buffer+eax], 0
        inc esi
        jmp %%byte_loop
        %%end_byte_loop:
        dec ecx
        mov ebx, [ebx+1]
        jmp %%loop
    %%end:
    popad
%endmacro

%macro print_binary_buffer_in_octal 1
    ; %1- number of bytes to read
    push ebx        ; back-up the reg that holds the linked list address
    mov eax, %1
    mov ebx, print_buffer
    add ebx, 80
    dec ebx
    mov byte [ebx], 0
    %%loop:
        cmp eax, 0
        jle %%print_without_leading_zeroes
        dec eax
        xor ecx, ecx
        mov byte cl, [binary_buffer+eax]
        cmp eax, 0
        jle %%write_to_buffer
        dec eax
        xor edx, edx
        mov byte dl, [binary_buffer+eax]
        shl dl, 1
        or cl, dl
        cmp eax, 0
        jle %%write_to_buffer
        dec eax
        xor edx, edx
        mov byte dl, [binary_buffer+eax]
        shl dl, 2
        or cl, dl
        %%write_to_buffer:
        add cl, 48
        dec ebx
        mov byte [ebx], cl
        jmp %%loop
    %%print_without_leading_zeroes:
    cmp byte [ebx], 48
    jg %%finish
    jl %%end
    inc ebx
    jmp %%print_without_leading_zeroes
    %%finish:
    mov byte [bool2], 1
    %%end:
    cmp byte [bool2],1
    je %%end2
    dec ebx
    %%end2:
    print_to_stdout ebx
    print new_line
    mov byte [bool2],0
    pop ebx
%endmacro

%macro free_link 1
    pushad
    push %1
    call free
    add esp, 4
    popad
%endmacro

section .rodata
    calc_string: db "calc: ",0
    overflow_error_msg: db "Error: Operand Stack Overflow",10,0
    underflow_error_msg: db "Error: Insufficient Number of Arguments on Stack",10,0
    new_line: db 10,0
    format: db "%d",0
    pointer_format: db "%p",10,0
    string_format: db "%s",0
    debug_msg: db "DEBUG: ",0
    debug_msg_pushed: db "pushed to stack: ",0
    debug_msg_input: db "got from user: ",0

section .data
    debug: db 0
    base: dd 8
    stack_capacity: dd 5
    number_of_operations: dd 0
    stack_size: dd 0
    bool: db 0
    bool2: db 0
    carry: db 0

section .bss
    input_buffer: resd 80
    new_buffer: resd 80
    binary_buffer: resb 240
    popped_link: resd 1
    print_buffer: resb 80
    operands_stack: resd 1

section .text
    align 16
    global main
    extern printf
    extern fprintf
    extern fflush
    extern fgets
    extern malloc
    extern calloc
    extern free
    extern stdin
    extern stdout
    extern stderr
main:
    push ebp    
    mov ebp, esp 
    mov ecx, [ebp+8]                                ;argc
    cmp ecx, 1
    je no_arguments
    check_for_debug [ebp+12], ecx
    
    mov eax, [ebp+12]                               ;argv 
    add eax, 4                                      ;argv[1]
    push dword [eax]
    call count_digits                               ;return value to ecx
    add esp, 4

    push ecx                                        ;push the number of digits
    mov eax, [ebp+12]
    add eax, 4
    push dword [eax]                                ;push the address of the argument string
    call convert_octal_string_to_decimal
    add esp, 8
    no_arguments:
        my_calloc [stack_capacity], operands_stack
        call claculator
    end:
        call free_stack
        mov eax, [number_of_operations]
        push eax
        call convert_decimal_to_octal
        print_number ecx
        print new_line
        ;exit
        mov     eax,1
        int     0x80

claculator:
    push ebp
    mov ebp,esp
    .infinite_loop:
    print calc_string
    get_input
    cmp byte [input_buffer], 'q'
    je .end

    cmp byte [input_buffer], 'p'
    jne .notP
    inc dword [number_of_operations]
    cmp dword [stack_size], 0
    jg .apply_pop
    print underflow_error_msg
    jmp .infinite_loop
    .apply_pop:
        call pop_operand
        mov eax, [popped_link]
        push eax
        call count_linked_list_length    ;return value in ecx
        pop eax
        convert_linked_list_to_binary_array eax, ecx
        mov ebx, eax
        mov eax, 8
        mul ecx
        print_binary_buffer_in_octal eax
        push ebx
        call free_linked_list
        add esp, 4
        dec dword [stack_size]
        call print_debug_msg
        jmp .infinite_loop

    .notP:
        cmp byte [input_buffer], 'd' 
        jne .notD
        inc dword [number_of_operations]
        cmp dword [stack_size], 0
        jg .not_empty
        print underflow_error_msg
        jmp .infinite_loop
        .not_empty:
            mov eax, [stack_capacity]
            cmp eax, [stack_size]
            jg .apply_duplicate
            print overflow_error_msg
            jmp .infinite_loop
        .apply_duplicate:
            call pop_operand
            push dword [popped_link]
            call duplicate_linked_list
            add esp, 4
            inc dword [stack_size]
            call print_debug_msg
            jmp .infinite_loop

    .notD:
        cmp byte [input_buffer], '&' 
        jne .notAnd
        inc dword [number_of_operations]
        cmp dword [stack_size], 2
        jge .apply_and
        print underflow_error_msg
        jmp .infinite_loop
        .apply_and:
            pushad
            call pop_operand
            dec dword [stack_size]
            popad
            mov eax, [popped_link]
            pushad
            call pop_operand
            dec dword [stack_size]
            popad
            mov ebx, [popped_link]
            push eax
            push ebx
            call apply_and_on_2_linked_lists
            pop ebx
            pop eax
            pushad
            push eax
            call free_linked_list
            add esp, 4
            popad
            pushad
            push ebx
            call free_linked_list
            add esp, 4
            popad
            call print_debug_msg
            jmp .infinite_loop

    .notAnd:
        cmp byte [input_buffer], 'n'
        jne .notN
        inc dword [number_of_operations]
        cmp dword [stack_size], 0
        jg .apply_n
        print underflow_error_msg
        jmp .infinite_loop
        .apply_n:
        call pop_operand
        dec dword [stack_size]
        mov ebx, [popped_link]
        push ebx
        call count_linked_list_length    ;returned value in ecx
        pop ebx
        push ebx
        call free_linked_list
        add esp,4
        push ecx 
        call convert_decimal_to_octal
        add esp, 4
        push ecx
        call convert_octal_to_string
        add esp, 4
        push esi
        push dword new_buffer
        call convert_to_hex_and_push
        add esp, 8
        call print_debug_msg
        jmp .infinite_loop
    
    .notN:
        cmp byte [input_buffer], '+' 
        jne .not_add
        inc dword [number_of_operations]
        cmp dword [stack_size], 2
        jge .apply_add
        print underflow_error_msg
        jmp .infinite_loop
        .apply_add:
        pushad
        call pop_operand
        dec dword [stack_size]
        popad
        mov eax, [popped_link]
        pushad
        call pop_operand
        dec dword [stack_size]
        popad
        mov ebx, [popped_link]
        push eax
        push ebx
        call apply_add_on_two_linked_lists
        pop ebx
        pop eax
        pushad
        push eax
        call free_linked_list
        add esp, 4
        popad
        pushad
        push ebx
        call free_linked_list
        add esp, 4
        popad
        call print_debug_msg
        jmp .infinite_loop

    .not_add:
    mov eax, [stack_capacity]
    cmp eax, [stack_size]
    jg .stack_has_room
    print overflow_error_msg
    jmp .infinite_loop
    .stack_has_room:    
    call print_debug_msg
    push dword input_buffer
    call count_digits   ;return value in ecx
    add esp,4

    push ecx
    push dword input_buffer
    call convert_to_hex_and_push
    add esp, 8
    jmp .infinite_loop
    .end:
    pop ebp 
    ret

count_linked_list_length:
    ;return value in ecx
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;the linked list address
    mov ecx, 0
    .loop:
    inc ecx
    cmp dword [eax+1], 0
    je .done
    mov eax, [eax+1]
    jmp .loop
    .done:
    pop ebp
    ret

count_digits:
    push ebp
    mov ebp,esp
    mov eax, [ebp+8]
    mov ecx, 0
    .loop:
    cmp byte [eax], 0
    je .done
    cmp byte [eax], 10
    je .done
    inc ecx
    inc eax
    jmp .loop
    .done:
    pop ebp
    ret 

convert_octal_string_to_decimal:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]        ;the string address
    mov ecx, [ebp+12]       ;number of digits

    cmp ecx, 0  
    je .done
    mov dword [stack_capacity], 0
    dec ecx
    xor eax, eax
    mov byte al, [ebx+ecx]
    sub byte al, 48
    add dword [stack_capacity], eax   
    dec ecx

    .loop:
    cmp ecx, -1
    je .done
    xor eax, eax
    mov byte al, [ebx+ecx]
    sub byte al, 48
    mul dword [base]
    add [stack_capacity], eax
    mov eax, 8
    mul dword [base]
    mov [base], eax
    dec ecx
    jmp .loop
    
    .done:
    pop ebp
    ret

pop_operand:
    push ebp
    mov ebp, esp
    mov ebx, [operands_stack]
    add ebx, [stack_size]
    add ebx, [stack_size]
    add ebx, [stack_size]
    add ebx, [stack_size]
    sub ebx, 4
    mov eax, [ebx]
    mov [popped_link], eax
    .done:
    pop ebp
    ret

free_linked_list:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;the linked list address
    mov ebx, [eax+1]    ;next link
    .loop:
    free_link eax
    cmp ebx, 0
    je .done
    mov eax, ebx
    mov ebx, [eax+1]
    jmp .loop
    .done:
    pop ebp
    ret

duplicate_linked_list:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;the linked list address
    mov ebx, [operands_stack]
    add ebx, [stack_size]
    add ebx, [stack_size]
    add ebx, [stack_size]
    add ebx, [stack_size]
    .loop:

    pushad
    push ebx
    push eax
    call duplicate_link
    add esp, 8
    popad

    cmp dword [eax+1], 0
    je .done
    mov ebx, [ebx]
    inc ebx
    mov eax, [eax+1]
    jmp .loop
    .done:
    pop ebp
    ret

duplicate_link:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;address to the link to duplicate
    mov ebx, [ebp+12]   ;address to save the new link
    my_malloc 5, ebx
    xor ecx, ecx
    mov byte cl, [eax]
    mov ebx, [ebx]
    mov byte [ebx], cl
    cmp dword [eax+1],0
    jne .end
    mov dword [ebx+1],0
    .end:
    pop ebp
    ret
convert_to_hex_and_push:
    ; %1- buffer adress, %2- number of bytes to read
    push ebp
    mov ebp, esp
    mov edi, [ebp+8]
    mov eax, [ebp+12]
    mov ecx, 0
    .input_loop:
    cmp eax, ecx
    je .start_allocating
    mov byte bl,[edi+ecx]
    sub byte bl, 48
    shl byte bl, 5
    mov edx, 0
    mov esi, ecx
    add esi, ecx
    add esi, ecx
    .char_loop:
        cmp edx, 3
        je .finished_char
        shl byte bl, 1
        jnc .zero_bit
        mov byte [binary_buffer+esi+edx],1
        inc edx
        jmp .char_loop
        .zero_bit:
        mov byte [binary_buffer+esi+edx],0
        inc edx
        jmp .char_loop
    .finished_char:
    inc ecx
    jmp .input_loop
    .start_allocating:
    ;;**** get number of bytes of the binary number ****
    mov ebx, 3
    mul ebx
    mov ebx, eax
    .add_to_stack:
    cmp ebx, 0
    je .end
    xor ecx, ecx
    cmp ebx, 8
    jl .less_than_8_bytes
    sub ebx, 8
    mov edx, 3
    convert_4_bytes_to_hex binary_buffer, ebx
    shl ecx, 4
    add ebx, 4
    convert_4_bytes_to_hex binary_buffer, ebx
    sub ebx, 4
    jmp .start_pushing
    .less_than_8_bytes:
    convert_less_than_8_to_hex binary_buffer, ebx
    mov ebx, 0
    cmp byte cl, 0
    jne .start_pushing
    cmp byte [bool], 1
    je .end
    ;*** now the ecx (or the cl) has the hex 
    ;*** representation of the last 8 bits
    .start_pushing:
    mov eax, [operands_stack]
    add eax, [stack_size]
    add eax, [stack_size]
    add eax, [stack_size]
    add eax, [stack_size]
    cmp byte [bool], 1
    je .search_last_link
    my_malloc 5, eax
    mov eax, [eax]
    mov byte [eax], cl
    mov dword [eax+1], 0
    mov byte [bool], 1
    jmp .add_to_stack
    .search_last_link:
    mov eax, [eax]
    inc eax
    cmp dword [eax], 0
    je .add_here
    jmp .search_last_link
    .add_here:
    my_malloc 5, eax
    mov edx, [eax]
    mov byte [edx], cl
    mov dword [edx+1], 0
    jmp .add_to_stack
    .end:
    mov byte [bool], 0
    inc dword [stack_size]
    pop ebp
    ret

apply_and_on_2_linked_lists:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;address to the first linked list
    mov ebx, [ebp+12]   ;address to the second linked list

    push ebx
    push eax
    call count_linked_list_length
    mov edx, ecx
    pop eax
    pop ebx

    push eax
    push ebx
    call count_linked_list_length
    pop ebx
    pop eax

    ; edx = the length of the first linked list (eax)
    ; ecx = the length of the second linked list (ebx)
    cmp edx, ecx
    jge .start
    mov ecx, edx
    .start:
    mov esi, ecx
    mov edx, [operands_stack]
    add edx, [stack_size]
    add edx, [stack_size]
    add edx, [stack_size]
    add edx, [stack_size]
    .loop:
    cmp esi, 0
    je .end
    my_malloc 5, edx
    xor ecx, ecx
    mov byte cl, [ebx]
    and byte cl, [eax]
    mov edx, [edx]
    mov byte [edx], cl
    inc edx
    mov dword [edx], 0
    dec esi
    mov eax, [eax+1]
    mov ebx, [ebx+1]
    jmp .loop

    .end:
    inc dword [stack_size]
    pop ebp
    ret

convert_decimal_to_octal:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]    ;get the number to convert
    mov esi, 0          ;this is sufficient to our assignment(a byte is sufficient to store number of links in list)
    mov ecx, 0
    .loop:
    xor edx, edx
    cmp esi,8 
    je .end
    shr byte bl,1
    inc esi
    jnc .n1
    or edx, 1
    .n1:
    cmp esi, 8
    je .n3
    shr byte bl, 1
    inc esi
    jnc .n2
    or edx, 2
    .n2:
    cmp esi, 8
    je .n3
    shr byte bl, 1
    inc esi
    jnc .n3
    or edx, 4
    .n3:
    mov eax, edx
    cmp esi, 3
    jle .not_greater_than_3
    cmp esi, 6
    jle .not_greater_than_6
    mov dword [base], 100
    mul dword [base]
    jmp .not_greater_than_3
    .not_greater_than_6:
    mov dword [base], 10
    mul dword [base]
    .not_greater_than_3:
    add ecx, eax
    jmp .loop
    .end:
    mov dword [base], 8
    pop ebp
    ret

convert_octal_to_string:
    ;saves the string to new_buffer
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;get the number to convert

    ;count number of digits
    mov ecx, 0
    mov dword [base], 10
    .count_digits:
    cmp eax, 0
    je .done_counting
    xor edx, edx
    div dword [base]
    inc ecx
    jmp .count_digits
    .done_counting:
    mov esi, ecx
    mov eax, [ebp+8]    ;get the number to convert
    mov byte [new_buffer+ecx], 0
    dec ecx
    mov ebx, 10
    .loop:
    cmp eax, 0
    je .end
    xor edx, edx
    div ebx
    add edx, 48
    mov byte [new_buffer+ecx], dl
    dec ecx
    jmp .loop
    .end:
    mov dword [base], 8
    pop ebp
    ret

apply_add_on_two_linked_lists:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;address to the first linked list
    mov ebx, [ebp+12]   ;address to the second linked list

    push ebx
    push eax
    call count_linked_list_length
    mov esi, ecx
    pop eax
    pop ebx

    push eax
    push ebx
    call count_linked_list_length
    mov edi, ecx
    pop ebx
    pop eax
    
    ; NOTE: at this point:
    ; esi = the length of the first linked list (eax)
    ; edi = the length of the second linked list (ebx)
    cmp edi, esi
    jge .start
    xchg edi, esi
    xchg eax, ebx
    ; NOTE: at this point:
    ; esi = the length of the smaller linked list
    ; edi = the length ofthe bigger linked list
    ; eax = the smaller linked list
    ; ebx = the bigger linked list
    .start:
    mov edx, [operands_stack]
    add edx, [stack_size]
    add edx, [stack_size]
    add edx, [stack_size]
    add edx, [stack_size]
    .smaller_loop:
    cmp esi, 0
    je .end_smaller_loop
    xor ecx, ecx
    mov byte cl, [eax]
    cmp byte [carry],0
    je .smaller_add_no_carry
    stc 
    adc byte cl, [ebx]
    jc .smaller_c
    mov byte [carry], 0
    .smaller_c:
    my_malloc 5, edx
    mov edx, [edx]
    mov byte [edx], cl
    inc edx
    mov dword [edx], 0
    dec esi
    dec edi
    mov eax, [eax+1]
    mov ebx, [ebx+1]
    jmp .smaller_loop
    .smaller_add_no_carry:
    add byte cl, [ebx]
    jnc .smaller_nc
    mov byte [carry], 1
    .smaller_nc:
    my_malloc 5, edx
    mov edx, [edx]
    mov byte [edx], cl
    inc edx
    mov dword [edx], 0
    dec esi
    dec edi
    mov eax, [eax+1]
    mov ebx, [ebx+1]
    jmp .smaller_loop 
    .end_smaller_loop:


    .bigger_loop:
    cmp edi, 0
    je .end_bigger_loop
    xor ecx, ecx
    mov byte cl, [ebx]
    cmp byte [carry],0
    je .bigger_add_no_carry
    stc 
    adc byte cl, 0
    jc .bigger_c_1
    mov byte [carry], 0
    .bigger_c_1:
    my_malloc 5, edx
    mov edx, [edx]
    mov byte [edx], cl
    inc edx
    mov dword [edx], 0
    dec edi
    mov ebx, [ebx+1]
    jmp .bigger_loop
    .bigger_add_no_carry:
    my_malloc 5, edx
    mov edx, [edx]
    mov byte [edx], cl
    inc edx
    mov dword [edx], 0
    dec edi
    mov ebx, [ebx+1]
    jmp .bigger_loop 
    .end_bigger_loop:

    cmp byte [carry], 0
    je .end
    my_malloc 5, edx
    mov edx, [edx]
    mov byte [edx], 1
    inc edx
    mov dword [edx], 0

    .end:
    inc dword [stack_size]
    pop ebp
    ret

free_stack:
    push ebp
    mov ebp, esp
    .loop:
    cmp dword [stack_size],0
    je .end
    call pop_operand
    mov eax, [popped_link]
    dec dword [stack_size]
    push eax
    call free_linked_list
    add esp, 4
    jmp .loop

    .end:
    mov eax, [operands_stack]
    push eax
    call free
    add esp, 4
    pop ebp
    ret

print_stack:
    push ebp
    pushad
    mov ebp, esp
    mov eax, [operands_stack]
    add eax, [stack_size]
    add eax, [stack_size]
    add eax, [stack_size]
    add eax, [stack_size]
    sub eax, 4
    .loop:
    cmp eax, [operands_stack]
    jl .end
    mov ebx, [eax]
    print_number ebx
    print new_line
    sub eax, 4
    jmp .loop

    .end:
    popad
    pop ebp
    ret

print_debug_msg:
    push ebp
    pushad
    mov ebp, esp

    cmp byte [debug], 0
    je .end
    cmp byte [input_buffer], '&'
    je .print_pushed_number
    cmp byte [input_buffer], '+'
    je .print_pushed_number
    cmp byte [input_buffer], 'n'
    je .print_pushed_number
    cmp byte [input_buffer], 'd'
    je .print_pushed_number
    cmp byte [input_buffer], 'p'
    je .end
    .print_input:
    print debug_msg
    print debug_msg_input
    mov eax, input_buffer
    print eax
    jmp .end
    .print_pushed_number:
    print debug_msg
    print debug_msg_pushed
    call pop_operand
    mov ebx, [popped_link]
    push ebx
    call count_linked_list_length
    pop ebx
    convert_linked_list_to_binary_array ebx, ecx
    mov eax, 8
    mul ecx
    print_binary_buffer_in_octal eax
    .end:
    popad
    pop ebp
    ret
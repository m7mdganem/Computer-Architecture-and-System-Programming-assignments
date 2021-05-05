section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string

section .bss			                     ; we define (global) uninitialized variables in .bss section
	an: resb 33		                         ; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	readenBitsFromCurrentChar: resb 1        ; number of readin bits from the current char in the word
	numberOfReadenOnes: resb 1               ; number of readen ones in the word -> will help us ignoring left most zeroes
	returnValue: resb 1						 ; the return value

section .text
	global convertor
	extern printf

convertor:
	push ebp
	mov ebp, esp	
	pushad			

	mov ecx, dword [ebp+8]								   	   ; get function argument (pointer to string)

	mov ebx,0                                                  ; counter that helps us to point to the right char in the string
	mov edx,0                                                  ; counter that helps us to point to the current location in an (the returned string)
	mov byte [numberOfReadenOnes],0                            ; initialize number of readen ones in the word to zero -> will help us to ignore left most zeroes

	mainLoop:
		mov byte [readenBitsFromCurrentChar],0                 ; define number of readin bits from the current char in the word to zero
		jmp checkNumberOrLetter                                ; get the binary representation of the char (according to ascii)

		continueConv:
			shl byte [ecx+ebx],1                               ; get the left most bit
			inc byte [readenBitsFromCurrentChar]               ; increase the number of readen bits
			jc lastBitOne                                      ; if the last bit is one jump to lastBitOne
			cmp byte [numberOfReadenOnes],0
			jz con                                    ; if we did not read 1 at all till now then ignore the zero
			mov byte [an+edx],48                               ; add zero to the end of the returned string
			inc edx
			con:
			cmp byte [readenBitsFromCurrentChar],4
			jnz continueConv                                   ; if we did'nt read 4 bits from the byte then continue reading bits 
			inc ebx
			jmp mainLoop                                       ; else increase ebx(point to the next char) and start over

		checkNumberOrLetter:
			cmp byte [ecx+ebx],113
			mov byte [returnValue],0
			jz endWithoutPrinting
			cmp byte [ecx+ebx],10
			jz newLine
			cmp byte [ecx+ebx],0
			mov byte [returnValue],1
			jz endWithNullTerminating                                             ; if we reached the null terminating char then jump to the end
			cmp byte [ecx+ebx],57
			jle number
			jg letter
			number:
				sub byte [ecx+ebx],48
				shl byte [ecx+ebx],4                           ; the first 4 bits are always zeroes
				jmp continueConv
			letter:
				sub byte [ecx+ebx],55
				shl byte [ecx+ebx],4                           ; the first 4 bits are always zeroes
				jmp continueConv
			newLine: 
				inc ebx
				jmp mainLoop                                   ; if the char is '\n' procceed to the next char and start over

		lastBitOne:
			inc byte [numberOfReadenOnes]
			mov byte [an+edx],49
			inc edx
			cmp byte [readenBitsFromCurrentChar],4
			jnz continueConv
			inc ebx
			jmp mainLoop         

	endWithNullTerminating:
		cmp byte [numberOfReadenOnes],0
		jnz end
		mov byte [an+edx],48
		inc edx	

	end:
		mov byte [an+edx],0
		push an												    ; call printf with 2 arguments -  
		push format_string										; pointer to str and pointer to format string
		call printf
		add esp, 8												; clean up stack after call

	endWithoutPrinting:
		popad			
		mov esp, ebp	
		pop ebp
		mov eax, [returnValue]
		ret
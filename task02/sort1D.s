section .data
    n	equ	12 	; кол элементов 
    i	dd	0  	; переменная внешнего цикла
    j	dd	0  	; переменная внутреннего цикла
    A	dd	123,2,33,214,5,546,74,8,39,10,-87,15
    sOut	db	'000000',0 ; строка для печати
    iOut	dd	6 ; макс. символов в строке, не длина!
section .text
    global _start
    extern	E_printTab
    extern	E_printEnter
    extern	E_printNumber
_start:
    ; First print call
    mov		esi,	A 	;  база массив
    mov		ecx,	n 	;  кол. элементов
    call    P_print
    call    E_printEnter
    ; Sorting started
    mov		esi,	A 	; повторять обязательно, могло испортиться!
    mov		ecx,	n 
    dec		ecx       	;  от 1 до n-1
    ;===================== 	; внешний цикл от 1 до n-1
L_for_i:
    push	ecx		; сохраняем кол. повторений, которые уменьшаются
    mov		ebx,	[i] 	; номер внешних повторения, который растет 
    mov		[j],	ebx  	; номер внутренних повторений, который растет
    inc		dword [j]   	; от i+1 до n
    mov		eax,	dword[esi+4*ebx] ; достанем из RAM элемент для ускорения работы
    ;---------------------  	; внутренний цикл от i+1 до n
L_for_j:
    push	ecx		; сохраняем кол. повторений
    mov		ebx,	[j]
    cmp		eax,	dword[esi+4*ebx]	;сравниваем элем в RAM с тем, который достали
    jle		L_if_true
    xchg   	eax,	dword[esi+4*ebx]	; меняем местами за 2 хода!!!
    mov		ebx,	[i]
    mov		[esi+4*ebx],	eax
L_if_true:
    inc		dword	[j]
    pop		ecx
    loop	L_for_j
    ;----------------------
    inc		dword	[i]
    pop		ecx
    loop	L_for_i
    ;======================
    ; Last print call
    mov		esi,	A
    mov		ecx,	n
    call    P_print
    jmp     L_exit
;=======================
; Printing begin ПОДПРОГРАММА
P_print:
    xor     ebx,    ebx
L_print_00:
    push	esi                 ;указатель на массив
    push	ebx                 ;номер текущего элемента
    push	ecx                 ;количество элементов    
    push	dword [esi+4*ebx]	;число - текущий элемент массива
    call	E_printNumber
    ;call	E_printTab
    pop		ecx
    pop		ebx
    pop		esi
    inc		ebx
    loop	L_print_00
    call    E_printEnter
    ret  ; выход из подпрограммы
;======================== 
L_exit:
    mov		eax,	1
    xor		ebx,	ebx
    int		80h
;========================================================================
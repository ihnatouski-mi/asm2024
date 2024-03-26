; no aguments
global E_printTab
; no arguments 
global E_printEnter
;  one argument (string)
global E_printStr
;  one argument (number)
global E_printNumber
; three arguments ([number],[length],string)
global E_Num2Str

section .data
    BUF_SIZE	equ     127	
    cSYS_WRITE	equ	    4
    cSTDIN	    equ	    0
    cSTDOUT	    equ	    1
    s09		    db	    0x09,0
    s0A		    db	    0x0A,0
    iDigit2Char	dd	    0
    iNegative	dd	    0
    ;sBuf	    db	    128 dup(0)
    iStrSize	dd	    0

section .bss
    sBuf        resd    128

section .text
;
;====================================================
;  prtint Tab
E_printTab:
    mov		eax,	cSYS_WRITE
    mov		ebx,	cSTDOUT
    mov		ecx,	s09
    mov		edx,	1
    int		80h
    ret
;
;====================================================
;  prtint Enter
E_printEnter:
    mov		eax,	cSYS_WRITE
    mov		ebx,	cSTDOUT
    mov		ecx,	s0A
    mov		edx,	1
    int		80h
    ret
;
;====================================================
;  Print a string
E_printStr:
    push	ebp
    mov		ebp,	esp
    mov		eax,	cSYS_WRITE
    mov		ebx,	cSTDOUT
    mov		ecx,	[ebp+8]
    mov		edx,	-1
L_printStr_1:	; length(str)
    inc		edx
    cmp		byte[ecx+edx],	0
    jg	L_printStr_1
    int		80h
    pop		ebp
    ret		4
;
;====================================================
;  Print a number 
E_printNumber:
    push	ebp
    mov		ebp,	esp
    mov		eax,	[ebp+8]
    push	eax    
    cld
    xor		eax,	eax    
    mov		ecx,	BUF_SIZE
    lea		esi,	[sBuf]
    lea		edi,	[sBuf]
    stosb	
    mov		dword [iStrSize],	0	
    pop		eax
    push	sBuf
    push	12   ; old number was 5
    push	eax
    call	E_Num2Str
    push	sBuf
    call	E_printStr			
    pop		ebp
    ret		4
;
;====================================================
;  Start of  'Num to string'
;
;  Digit to char
P_Digit2Char:
    ;mov		ax,	si	;high part of a divident
    mov		eax,	esi
    ;shr		esi,	16	;shift of low part of the divident
    ;mov		dx,	si	;low part of the divident
    xor		edx,	edx	
    mov		ecx,	10	;divider
    div		ecx
    add		dl,	0x30	;making a char by mixing the ASCII & the remainder
    mov		ebx,	[iDigit2Char]
    mov		[edi+ebx],	dl	;puting the char into string
    ret
;
;  insert minus to string
P_minus:
    dec		dword [iDigit2Char]
    mov		ebx,	[iDigit2Char]
    mov		byte[edi+ebx],		0x2D
    ret
;=============================================================================
;   Num to string  
E_Num2Str:;		BEGINING
    push	ebp
    mov		ebp,	esp
    mov		esi,		dword [ebp+8]		;input a number
    mov		ecx,		dword [ebp+12]		;a count of didits in the number
    mov		edi,		dword [ebp+16]		;pointer to a string
    mov		dword [iDigit2Char],	ecx
    mov		dword [iNegative],	0
    cmp		esi,	0
    jge		L_Num2Str_1
    mov		dword [iNegative],	1
    neg		esi
L_Num2Str_1:   ; fill the string by space
    mov		byte[edi+ecx-1],0x20
    loop	L_Num2Str_1
;
L_Num2Str_2:
    dec		dword [iDigit2Char]
    call	P_Digit2Char
    xor		esi,	esi
    mov		esi,	eax	;replacing the number with the quotinent 
    cmp		esi,	0
    jg		L_Num2Str_2
    cmp		dword [iNegative],	0
    je		L_Num2Str_3
    call	P_minus
L_Num2Str_3:
    pop		ebp
    ret		12
;
;=============================================================================
;=============================================================================

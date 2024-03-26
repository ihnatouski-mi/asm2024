     1                                  ; no aguments
     2                                  global E_printTab
     3                                  ; no arguments 
     4                                  global E_printEnter
     5                                  ;  one argument (string)
     6                                  global E_printStr
     7                                  ;  one argument (number)
     8                                  global E_printNumber
     9                                  ; three arguments ([number],[length],string)
    10                                  global E_Num2Str
    11                                  
    12                                  section .data
    13                                      BUF_SIZE	equ     127	
    14                                      cSYS_WRITE	equ	    4
    15                                      cSTDIN	    equ	    0
    16                                      cSTDOUT	    equ	    1
    17 00000000 0900                        s09		    db	    0x09,0
    18 00000002 0A00                        s0A		    db	    0x0A,0
    19 00000004 00000000                    iDigit2Char	dd	    0
    20 00000008 00000000                    iNegative	dd	    0
    21                                      ;sBuf	    db	    128 dup(0)
    22 0000000C 00000000                    iStrSize	dd	    0
    23                                  
    24                                  section .bss
    25 00000000 <res 200h>                  sBuf        resd    128
    26                                  
    27                                  section .text
    28                                  ;
    29                                  ;====================================================
    30                                  ;  prtint Tab
    31                                  E_printTab:
    32 00000000 B804000000                  mov		eax,	cSYS_WRITE
    33 00000005 BB01000000                  mov		ebx,	cSTDOUT
    34 0000000A B9[00000000]                mov		ecx,	s09
    35 0000000F BA01000000                  mov		edx,	1
    36 00000014 CD80                        int		80h
    37 00000016 C3                          ret
    38                                  ;
    39                                  ;====================================================
    40                                  ;  prtint Enter
    41                                  E_printEnter:
    42 00000017 B804000000                  mov		eax,	cSYS_WRITE
    43 0000001C BB01000000                  mov		ebx,	cSTDOUT
    44 00000021 B9[02000000]                mov		ecx,	s0A
    45 00000026 BA01000000                  mov		edx,	1
    46 0000002B CD80                        int		80h
    47 0000002D C3                          ret
    48                                  ;
    49                                  ;====================================================
    50                                  ;  Print a string
    51                                  E_printStr:
    52 0000002E 55                          push	ebp
    53 0000002F 89E5                        mov		ebp,	esp
    54 00000031 B804000000                  mov		eax,	cSYS_WRITE
    55 00000036 BB01000000                  mov		ebx,	cSTDOUT
    56 0000003B 8B4D08                      mov		ecx,	[ebp+8]
    57 0000003E BAFFFFFFFF                  mov		edx,	-1
    58                                  L_printStr_1:	; length(str)
    59 00000043 42                          inc		edx
    60 00000044 803C1100                    cmp		byte[ecx+edx],	0
    61 00000048 7FF9                        jg	L_printStr_1
    62 0000004A CD80                        int		80h
    63 0000004C 5D                          pop		ebp
    64 0000004D C20400                      ret		4
    65                                  ;
    66                                  ;====================================================
    67                                  ;  Print a number 
    68                                  E_printNumber:
    69 00000050 55                          push	ebp
    70 00000051 89E5                        mov		ebp,	esp
    71 00000053 8B4508                      mov		eax,	[ebp+8]
    72 00000056 50                          push	eax    
    73 00000057 FC                          cld
    74 00000058 31C0                        xor		eax,	eax    
    75 0000005A B97F000000                  mov		ecx,	BUF_SIZE
    76 0000005F 8D35[00000000]              lea		esi,	[sBuf]
    77 00000065 8D3D[00000000]              lea		edi,	[sBuf]
    78 0000006B AA                          stosb	
    79 0000006C C705[0C000000]0000-         mov		dword [iStrSize],	0	
    79 00000074 0000               
    80 00000076 58                          pop		eax
    81 00000077 68[00000000]                push	sBuf
    82 0000007C 680C000000                  push	12   ; old number was 5
    83 00000081 50                          push	eax
    84 00000082 E837000000                  call	E_Num2Str
    85 00000087 68[00000000]                push	sBuf
    86 0000008C E89DFFFFFF                  call	E_printStr			
    87 00000091 5D                          pop		ebp
    88 00000092 C20400                      ret		4
    89                                  ;
    90                                  ;====================================================
    91                                  ;  Start of  'Num to string'
    92                                  ;
    93                                  ;  Digit to char
    94                                  P_Digit2Char:
    95                                      ;mov		ax,	si	;high part of a divident
    96 00000095 89F0                        mov		eax,	esi
    97                                      ;shr		esi,	16	;shift of low part of the divident
    98                                      ;mov		dx,	si	;low part of the divident
    99 00000097 31D2                        xor		edx,	edx	
   100 00000099 B90A000000                  mov		ecx,	10	;divider
   101 0000009E F7F1                        div		ecx
   102 000000A0 80C230                      add		dl,	0x30	;making a char by mixing the ASCII & the remainder
   103 000000A3 8B1D[04000000]              mov		ebx,	[iDigit2Char]
   104 000000A9 88141F                      mov		[edi+ebx],	dl	;puting the char into string
   105 000000AC C3                          ret
   106                                  ;
   107                                  ;  insert minus to string
   108                                  P_minus:
   109 000000AD FF0D[04000000]              dec		dword [iDigit2Char]
   110 000000B3 8B1D[04000000]              mov		ebx,	[iDigit2Char]
   111 000000B9 C6041F2D                    mov		byte[edi+ebx],		0x2D
   112 000000BD C3                          ret
   113                                  ;=============================================================================
   114                                  ;   Num to string  
   115                                  E_Num2Str:;		BEGINING
   116 000000BE 55                          push	ebp
   117 000000BF 89E5                        mov		ebp,	esp
   118 000000C1 8B7508                      mov		esi,		dword [ebp+8]		;input a number
   119 000000C4 8B4D0C                      mov		ecx,		dword [ebp+12]		;a count of didits in the number
   120 000000C7 8B7D10                      mov		edi,		dword [ebp+16]		;pointer to a string
   121 000000CA 890D[04000000]              mov		dword [iDigit2Char],	ecx
   122 000000D0 C705[08000000]0000-         mov		dword [iNegative],	0
   122 000000D8 0000               
   123 000000DA 81FE00000000                cmp		esi,	0
   124 000000E0 7D0C                        jge		L_Num2Str_1
   125 000000E2 C705[08000000]0100-         mov		dword [iNegative],	1
   125 000000EA 0000               
   126 000000EC F7DE                        neg		esi
   127                                  L_Num2Str_1:   ; fill the string by space
   128 000000EE C6440FFF20                  mov		byte[edi+ecx-1],0x20
   129 000000F3 E2F9                        loop	L_Num2Str_1
   130                                  ;
   131                                  L_Num2Str_2:
   132 000000F5 FF0D[04000000]              dec		dword [iDigit2Char]
   133 000000FB E895FFFFFF                  call	P_Digit2Char
   134 00000100 31F6                        xor		esi,	esi
   135 00000102 89C6                        mov		esi,	eax	;replacing the number with the quotinent 
   136 00000104 81FE00000000                cmp		esi,	0
   137 0000010A 7FE9                        jg		L_Num2Str_2
   138 0000010C 813D[08000000]0000-         cmp		dword [iNegative],	0
   138 00000114 0000               
   139 00000116 7405                        je		L_Num2Str_3
   140 00000118 E890FFFFFF                  call	P_minus
   141                                  L_Num2Str_3:
   142 0000011D 5D                          pop		ebp
   143 0000011E C20C00                      ret		12
   144                                  ;
   145                                  ;=============================================================================
   146                                  ;=============================================================================

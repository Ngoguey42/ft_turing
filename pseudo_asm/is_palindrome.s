;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    is_palindrome.s                                    :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 12:43:53 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/05 18:11:50 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"is_palindrome"
	alphabet[.uyn+-=01]
	blank[.]

; .abcba.
; .abcba.L.R
; ..bcba.L.-aR
; ...cba.L.-a-bR
; ....ba.L.-a-b-cR
; .....a.L.-a-b-c-bR
; .......L.-a-b-c-b-aR
; .....a.L.-a-b-c-b+aR
; ....ba.L.-a-b-c+b+aR
; ...cba.L.-a-b+c+b+aR
; ..bcba.L.-a+b+c+b+aR
; .abcba.L.+a+b+c+b+aR
; .abcba.L.-a+b+c+b+aR
; .abcba.L.-a+b+c+b-aR
; .abcba.L.-a-b+c+b-aR
; .abcba.L.-a-b+c-b-aR
; .abcba.
; .abcbay


; subroutine main
main:
	__		[.]				E	jmp print_y
	|		[ANY]			E	call init_buffer

ItoB: ;works on non-empty input
	__		[ANY]	(.)		E	call+ ItoB_carry
	__		[.]		(R)		E	call bufcharflag_endl
	__		[L]				L	ni
	__		[.]				L	ni
	__		[.]				R	jmp BtoI_init		;exit condition
	|		[ANY]			E	call input_beginl
	__		[ANY]			E	jmp ItoB			;loop condition

BtoI_init:
	__		[.]				R	call bufcharflag_beginr

BtoI:
	__		[-]		(+)		R	ni
	__		[ANY]			L	call+ BtoI_carry
	__		[ANY]			E	call input_endr
	__		[.]				R	call BtoI_reachnext
	__		[-]				E	jmp BtoI			;loop condition
	|		[L]				E	ni					;exit condition


	__		[L]				E	call bufcharflag_nextr

Check:
	__		[+]		(-)		R	ni
	__		[ANY]			E	call+ Check_carry


; subroutine 1
init_buffer:
	__		[ANY]			E	call input_endr
	__		[.]				R	ni
	__		[.]		(L)		R	ni
	__		[.]				R	ni
	__		[.]		(R)		L	ni
	__		[.]				L	ni
	__		[L]				L	ni
	__		[.]				L	call input_beginl
	__		[ANY]			E	ret

; subroutine 2
ItoB_carry:
	__		[.]				R	ni
	__		[.]				E	ni
	|		[ANY]			E	call input_endr
	__		[.]				R	call bufcharflag_endr
	__		[R]		(-)		R	ni
	__		[.]		(SPEC)	R	ret

; subroutine 3
BtoI_carry:
	__		[+]				E	call bufcharflag_endl
	__		[L]				L	ni
	__		[.]				L	ni
	__		[.]		(SPEC)	E	ret-
	|		[ANY]			E	call input_endl
	__		[.]		(SPEC)	E	ret-

; subroutine 4
BtoI_reachnext:
	__		[L]				E	call bufcharflag_firstplusr
	__		[+]				L	ni
	__		[ANY]			L	ret

; subroutine 5
Check_carry:
; 	__

; subroutines general
bufcharflag_endl: ;from any bufchar_flag
	__		[L]		E	ret
	|		[R+-]	L	ni
	__		[ANY]	L	jmp bufcharflag_endl

bufcharflag_endr: ;from any bufchar_flag
	__		[R]		E	ret
	|		[L+-]	R	ni
	__		[ANY]	R	jmp bufcharflag_endr

bufcharflag_beginr: ;from any bufchar_flag
	__		[R]		L	jmp _bufcharflag_beginr
	|		[L+-]	R	ni
	__		[ANY]	R	jmp bufcharflag_endr
_bufcharflag_beginr:
	__		[ANY]	L	ret

bufcharflag_firstplusr: ; from any bufchar_flag
	__		[+]		E	ret
	|		[-L]	R	ni
	__		[ANY]	R	jmp bufcharflag_firstplusr

bufcharflag_nextr: ;from any bufchar_flag but R
	__		[L+-]	R	ni
	__		[ANY]	R	ret

input_beginl: ;from non-empty input
	__		[ANY]	L	rep
	|		[.]		R	ret

input_endl: ;from non-empty input
	__		[ANY]	L	rep
	|		[.]		E	ret

input_endr: ;from non-empty input
	__		[ANY]	R	rep
	|		[.]		E	ret

print_y:
	__		[.]		(y)		R	halt

print_n:
	__		[.]		(n)		R	halt

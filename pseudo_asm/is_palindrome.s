;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    is_palindrome.s                                    :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 12:43:53 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/04 17:53:50 by ngoguey          ###   ########.fr        ;
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

; subroutine main
main:
	__		[.]				E	jmp print_y
	|		[ANY]			E	call init_buffer

ItoB: ;works on non-empty input
	__		[ANY]	(.)		E	call+ ItoB_carry
	__		[.]		(R)		E	call bufcharflag_endl
	__		[L]				L	ni
	__		[.]				L	ni
	__		[.]				?	ni
	|		[ANY]			E	call input_beginl
	__		[ANY]			E	jmp ItoB

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


; subroutines general
bufcharflag_endl: ;from any bufchar_flag
	__		[L]		ret							E
	|		[R+-]	ni							L
	_		[ANY]	jmp bufcharflag_endl		L

bufcharflag_endr: ;from any bufchar_flag
	__		[R]		ret							E
	|		[L+-]	ni							R
	_		[ANY]	jmp bufcharflag_endr		R


input_beginl: ;from non-empty input
	__		[ANY]	rep							L
	|		[.]		ret							R

input_endl: ;from non-empty input
	__		[ANY]	rep							L
	|		[.]		ret							E

input_endr: ;from non-empty input
	__		[ANY]	rep							R
	|		[.]		ret							E

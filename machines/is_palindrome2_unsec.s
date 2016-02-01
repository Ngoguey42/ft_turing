;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    is_palindrome2.s                                   :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/06 17:52:34 by ngoguey           #+#    #+#              ;
;    Updated: 2016/02/01 18:15:38 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; checks if the input is a palindrome or not, drops y/n at the end
; all chars accepted in input, rapes the original input

	name"is_palindrome2_unsec"
	alphabet[.A]
	blank[.]

main_left:
	__		[.]				R	halt ; no more chars on tape
	|		[ANY]	(.)		R	call+ carry_right
	__		[.]				L	ni
	; |		[ANY]			R	jmp print_n

main_right:
	__		[.]				R	halt ; no more chars on tape
	|		[ANY]	(.)		L	call+ carry_left
	__		[.]				R	jmp main_left
	; |		[ANY]			R	jmp print_n_from_left

carry_right:
	__		[.]				L	ni
	|		[ANY]			R	rep
	__		[.]				R	halt ;last of an odd number of chars
	|		[SPEC]	(.)		E	ret-
	|		[ANY]			E	ret-

carry_left:
	__		[.]				R	ni
	|		[ANY]			L	rep
	__		[.]				R	halt ;last of an odd number of chars
	|		[SPEC]	(.)		E	ret-
	|		[ANY]			E	ret-

; print_n:
; 	__		[.]		(n)		R	halt

; print_n_from_left:
; 	__		[.]		(n)		R	halt
; 	|		[ANY]			R	rep

;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    is_palindrome2.s                                   :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/06 17:52:34 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/06 19:16:44 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"is_palindrome2"
	alphabet[.ynQWERTYUIOP]
	blank[.]

main:
	__		[.]				E	jmp print_y
	|		[ANY]	(.)		R	call+ carry_right
	__		[.]				L	ni
	|		[ANY]			R	jmp print_n
	__		[.]				R	jmp main
	|		[ANY]			L	rep

carry_right:
	__		[.]				L	ni
	|		[ANY]			R	rep
	__		[.]				E	jmp print_y ;last of an odd number of chars
	|		[SPEC]	(.)		E	ret-
	|		[ANY]			E	ret-

print_y:
	__		[.]		(y)		R	halt

print_n:
	__		[.]		(n)		R	halt

;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    zero_second_to_last.s                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 17:03:51 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/06 19:47:43 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; is penultimate digit a 0, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "6/65" @2m30

	name"zero_second_to_last"
	alphabet[01.ny]
	blank[.]

got_none:
	__		[.]			E	jmp print_n
	|		[1]			R	rep
	|		[0]			R	ni

got_zero:
	__		[.]			E	jmp print_n
	|		[0]			R	rep
	|		[1]			R	ni

got_zero_one:
	__		[.]			E	jmp print_y
	|		[1]			R	jmp got_none
	|		[0]			R	jmp got_zero


print_y:
	__		[.]		(y)	R	halt

print_n:
	__		[.]		(n)	R	halt

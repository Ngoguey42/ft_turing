;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    binary_divisable_by3.s                             :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 15:52:54 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/06 19:52:26 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; is this binary number divisable by 3, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "3/65" @22m15

	name"binary_divisable_by3"
	alphabet[01.ny]
	blank[.]

form_3x:
	__			[0]				R	rep
	|			[1]				R	jmp form_3x_p1
	|			[.]				L	jmp print_y

form_3x_p1:
	__			[0]				R	jmp form_3x_p2
	|			[1]				R	jmp form_3x
	|			[.]				L	jmp print_n

form_3x_p2:
	__			[0]				R	jmp form_3x_p1
	|			[1]				R	rep
	|			[.]				L	jmp print_n

print_y:
	__			[ANY]			R	ni
	__			[.]		(y)		R	halt

print_n:
	__			[ANY]			R	ni
	__			[.]		(n)		R	halt

;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    has_0011.s                                         :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 15:06:25 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/30 13:26:40 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; looks for the substring 0011 in the input, drops y/n at the end
; deduced from Youtube hhp3 "Theory of Computation" "3/65" @3m20

	name"has_0011"
	alphabet[01.ny]
	blank[.]

empty:
	__		[1]				R	rep
	|		[0]				R	ni
	|		[.]				E	jmp print_n

has_0:
	__		[0]				R	ni
	|		[1]				R	jmp empty
	|		[.]				E	jmp print_n
has_00: ; label unused
	__		[0]				R	rep
	|		[1]				R	ni
	|		[.]				E	jmp print_n
has_001: ; label unused
	__		[1]				R	ni
	|		[0]				R	jmp has_0
	|		[.]				E	jmp print_n
has_0011: ; label unused
	__		[ANY]			R	rep
	|		[.]				E	jmp print_y

print_y:
	__		[.]		(y)		R	halt

print_n:
	__		[.]		(n)		R	halt

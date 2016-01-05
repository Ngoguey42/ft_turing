;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    has_0011.s                                         :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 15:06:25 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/05 17:57:09 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; looks for the substring 0011 in the input, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "3/65" @3m20

	name"has_0011"
	alphabet[01.]
	blank[.]

empty:
	__		[1]				R	rep
	|		[0]				R	ni
	|		[.]				E	jmp print_n

has_0:
	__		[0]				R	ni
	|		[1]				R	jmp empty
	|		[.]				E	jmp print_n
	__		[0]				R	rep
	|		[1]				R	ni
	|		[.]				E	jmp print_n
	__		[1]				R	ni
	|		[0]				R	jmp has_0
	|		[.]				E	jmp print_n
	__		[ANY]			R	rep
	|		[.]				E	jmp print_y

print_y:
	__		[.]		(y)		R	halt

print_n:
	__		[.]		(n)		R	halt

;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    has_0011.s                                         :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 15:06:25 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/04 13:29:31 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; looks for the substring 0011 in the input, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "3/65" @3m20

	name"has_0011"
	alphabet[01.]
	blank[.]

empty:
	__		[1]		rep					R
	|		[0]		ni					R
	|		[.]		jmp print_n			E

has_0:
	__		[0]		ni					R
	|		[1]		jmp empty			R
	|		[.]		jmp print_n			E
	__		[0]		rep					R
	|		[1]		ni					R
	|		[.]		jmp print_n			E
	__		[1]		ni					R
	|		[0]		jmp has_0			R
	|		[.]		jmp print_n			E
	__		[ANY]	rep					R
	|		[.]		jmp print_y			E

print_y:
	s		[.]		ni					R	(y)
	f YES

print_n:
	s		[.]		ni					R	(n)
	f NO

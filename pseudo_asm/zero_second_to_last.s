;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    zero_second_to_last.s                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 17:03:51 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/04 13:43:42 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; is penultimate digit a 0, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "6/65" @2m30

	name"zero_second_to_last"
	alphabet[01.]
	blank[.]

got_none:
	__		[.]		jmp print_n				E
	|		[1]		rep						R
	|		[0]		ni						R

got_zero:
	__		[.]		jmp print_n				E
	|		[0]		rep						R
	|		[1]		ni						R

got_zero_one:
	__		[.]		jmp print_y				E
	|		[1]		jmp got_none			R
	|		[0]		jmp got_zero			R


print_y:
	__		[.]		ni						R	(y)
	f YES

print_n:
	__		[.]		ni						R	(n)
	f NO

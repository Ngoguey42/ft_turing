;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    zero_second_to_last.s                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 17:03:51 by ngoguey           #+#    #+#              ;
;    Updated: 2015/12/27 17:07:53 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; is penultimate digit a 0, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "6/65" @2m30

	name"zero_second_to_last"
	alphabet[01.]
	blank[.]

got_none:
	got_none			[.]		jmp print_n				R
	''					[1]		rep						R
	''					[0]		ni						R

got_zero:
	got_zero			[.]		jmp print_n				R
	''					[0]		rep						R
	''					[1]		ni						R

got_zero_one:
	got_zero_one		[.]		jmp print_y				R
	''					[1]		jmp got_none			R
	''					[0]		jmp got_zero			R


print_y:
	forward1y			[ANY]	ni						R
	puty				[.]		ni						R	(y)
	FINAL_YES

print_n:
	forward1n			[ANY]	ni						R
	putn				[.]		ni						R	(n)
	FINAL_NO

;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    binary_divisable_by3.s                             :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 15:52:54 by ngoguey           #+#    #+#              ;
;    Updated: 2015/12/27 15:58:52 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; is this binary number divisable by 3, drops y/n at the end
; deduced from Youtube hpp3 "Theory of Computation" "3/65" @22m15

	name"binary_divisable_by3"
	alphabet[01.]
	blank[.]

form_3x:
	form_3x				[0]		rep						R
	''					[1]		goto form_3x_p1			R
	''					[.]		goto print_y			L

form_3x_p1:
	form_3x_p1			[0]		goto form_3x_p2			R
	''					[1]		goto form_3x			R
	''					[.]		goto print_n			L

form_3x_p2:
	form_3x_p2			[0]		goto form_3x_p1			R
	''					[1]		rep						R
	''					[.]		goto print_n			L

print_y:
	forward1y			[ANY]	ni						R
	puty				[.]		ni						R	(y)
	FINAL_YES

print_n:
	forward1n			[ANY]	ni						R
	putn				[.]		ni						R	(n)
	FINAL_NO

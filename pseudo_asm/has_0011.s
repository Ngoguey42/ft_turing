;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    has_0011.s                                         :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 15:06:25 by ngoguey           #+#    #+#              ;
;    Updated: 2015/12/27 15:16:25 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; looks for the substring 0011 in the input, drops y/n at the end
; deduced from Youtube "hpp3", "Theory of Computation", "3/65", "5m00"

	name"has_0011"
	alphabet[01.]
	blank[.]

empty:
	nothing					[1]		rep				R
	''						[0]		ni				R
	''						[.]		goto print_n	L

has_0:
	has_0					[0]		ni				R
	''						[1]		goto empty		R
	''						[.]		goto print_n	L
	has_00					[0]		rep				R
	''						[1]		ni				R
	''						[.]		goto print_n	L
	has_001					[1]		ni				R
	''						[0]		goto has_0		R
	''						[.]		goto print_n	L
	has_0011				[ANY]	rep				R
	''						[.]		goto print_y	L

print_y:
	forward1y				[ANY]	ni				R
	puty					[ANY]	ni				R	(y)
	FINAL_YES

print_n:
	forward1n				[ANY]	ni				R
	putn					[ANY]	ni				R	(n)
	FINAL_NO

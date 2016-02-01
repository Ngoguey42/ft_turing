;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    binary_increment_unsec.s                           :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/02/01 20:08:22 by ngoguey           #+#    #+#              ;
;    Updated: 2016/02/01 20:08:51 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

    name"binary_increment_unsec"
	alphabet[10.]
	blank[.]

checkinput:
	__	[0]				R	rep
	|	[.]				L	jmp carry_one

carry_one:
	__	[0]		(1)		R	jmp goto_rightmost
	|	[1]		(0)		L	rep
	|	[.]				R	halt

goto_rightmost:
	__	[ANY]			R	rep
	|	[.]				L	jmp carry_one

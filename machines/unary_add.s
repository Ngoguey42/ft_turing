;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    unary_add.s                                        :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/25 14:47:31 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/25 15:02:10 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"unary_add"
	alphabet[1.+=]
	blank[.]

; ..........+=..
; .........1+=..
; .........+1=..
; ........1+1=..
; ..1111+1111=..

checkinput_1st_nbr:
	__			[1]			R		rep
	|			[+]			R		jmp checkinput_2nd_nbr
	|			[ANY]		R		jmp checkinput_invalid

checkinput_2nd_nbr:
	__			[1]			R		rep
	|			[=]			R		jmp checkinput_checkblank
	|			[ANY]		R		jmp checkinput_invalid

checkinput_checkblank:
	__			[.]			L		jmp kill_equal
	|			[ANY]		L		jmp checkinput_invalid

kill_equal:
	__			[=]	(.)		L		jmp kill_one_or_plus

kill_one_or_plus:
	__			[+]	(.)		L		jmp success
	|			[1] (.)		L		jmp search_n_destroy_plus


search_n_destroy_plus:
	__			[1]			L		rep
	|			[+] (1)		L		jmp success

success:
	__			[ANY]		R		halt


checkinput_invalid:
	__			[ANY]		R		halt

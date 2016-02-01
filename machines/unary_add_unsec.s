;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    unary_add.s                                        :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/25 14:47:31 by ngoguey           #+#    #+#              ;
;    Updated: 2016/02/01 17:24:59 by ngoguey          ###   ########.fr        ;
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

checkinput_2nd_nbr:
	__			[1]			R		rep
	|			[=]			R		jmp checkinput_checkblank

checkinput_checkblank:
	__			[.]			L		jmp kill_equal

kill_equal:
	__			[=]	(.)		L		jmp kill_one_or_plus

kill_one_or_plus:
	__			[+]	(.)		L		halt
	|			[1] (.)		L		jmp search_n_destroy_plus

search_n_destroy_plus:
	__			[1]			L		rep
	|			[+] (1)		L		halt

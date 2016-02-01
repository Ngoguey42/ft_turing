;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    unary_sub_unsec.s                                  :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/02/01 18:30:02 by ngoguey           #+#    #+#              ;
;    Updated: 2016/02/01 18:53:40 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"unary_sub_unsec"
	alphabet[1o.-=]
	blank[.]

checknbr1:
	__		[1]				R		rep
	|		[-]				R		ni
checknbr2:
	__		[1]				R		rep
	|		[=]				R		ni
checkblank:
	__		[.]				L		ni
	__		[=]		(.)		L		jmp eraseone


eraseone:
	__		[1]		(=)		L		jmp subone
	|		[-]		(.)		L		jmp restore

subone:
	__		[1]				L		rep
	|		[-]				L		jmp skip

skip:
	__		[o]				L		rep
	|		[1]		(o)		R		jmp scanright

scanright:
	__		[o-1]			R		rep
	|		[=]		(.)		L		jmp eraseone

restore:
	__		[o]		(.)		L		rep
	|		[1.]			L		halt
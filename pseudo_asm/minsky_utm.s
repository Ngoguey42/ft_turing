;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    minsky_utm.s                                       :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/10 19:57:27 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/10 20:26:44 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; ./ft_turing truc.json "110101110000010011011yyAyyAyy"
; copied from http://www.cba.mit.edu/events/03.11.ASE/docs/Minsky.pdf

	name"minsky_utm.s"
	alphabet[y01A]
	blank[0]

reach_y:
	__		[ANY]			R	rep
	|		[y]				E	jmp q2

q1:
	__		[y]		(0)		L	rep
	|		[0]		(0)		L	rep
	|		[1]		(1)		L	jmp q2
	|		[A]		(1)		L	rep

q2:
	__		[y]		(0)		L	jmp q1
	|		[0]		(y)		R	rep
	|		[1]		(A)		R	rep
	|		[A]		(y)		R	jmp q6

q3:
	__		[y]		(y)		L	rep
	|		[0]				R	halt
	|		[1]		(A)		L	rep
	|		[A]		(1)		L	jmp q4

q4:
	__		[y]		(y)		L	rep
	|		[0]		(y)		R	jmp q5
	|		[1]		(1)		L	jmp q7
	|		[A]		(1)		L	rep

q5:
	__		[y]		(y)		R	rep
	|		[0]		(y)		L	jmp q3
	|		[1]		(A)		R	rep
	|		[A]		(1)		R	rep

q6:
	__		[y]		(y)		R	rep
	|		[0]		(A)		L	jmp q3
	|		[1]		(A)		R	rep
	|		[A]		(1)		R	rep

q7:
	__		[y]		(0)		R	rep
	|		[0]		(y)		R	jmp q6
	|		[1]		(1)		R	rep
	|		[A]		(0)		R	jmp q2

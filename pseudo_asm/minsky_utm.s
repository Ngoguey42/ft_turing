;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    minsky_utm.s                                       :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/10 19:57:27 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/10 20:15:39 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"minsky_utm.s"
	alphabet[y01A]
	blank[0]

q2:
	__		[y]		(0)		L	jmp q1
	|		[0]		(y)		R	rep
	|		[1]		(A)		R	rep
	|		[A]		(y)		R	jmp q6

q1:
	__		[y]		(0)		L	rep
	|		[0]		(0)		L	rep
	|		[1]		(1)		L	jmp q2
	|		[A]		(1)		L	rep

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

;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    split_input.s                                      :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/08 12:09:38 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/19 14:48:16 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

;;;;;;;;;;;;;;;;
; abcde
;;;;;;;;;;;;;;;;
; abcd.e
;;;;;;;;;;;;;;;;
; abcd..e
; abc.d.e
;;;;;;;;;;;;;;;;
; abc.d..e
; abc..d.e
; ab.c.d.e
;;;;;;;;;;;;;;;;
; ab.c.d..e
; ab.c..d.e
; ab..c.d.e
; a.b.c.d.e
;;;;;;;;;;;;;;;;

; O(3n^2) time complexity
; O(2n) space complexity
; 275000 opt/sec
; 11.5 sec for N = 1000

	name"split_input"
	alphabet[abcde.]
	blank[.]

main:
	__		[.]				R	halt
	|		[ANY]			R	ni
	__		[ANY]			R	rep
	|		[.]				L	ni
	__		[ANY]			L	ni

scanleft_for_double_char2:
	__		[ANY]			L	call dummy
	__		[.]				R	halt
	|		[ANY]			R	ni
	__		[ANY]			R	jmp reach_last

reach_last:
	__		[.]				R	ni
	__		[.]				L	jmp end_found
	|		[ANY]			R	jmp reach_last

end_found:
	__		[.]				L	ni
char_to_carry:
	__		[ANY]	(.)		R	call+ carry_1right


	__		[.]				L	ni
	__		[.]				L	jmp char_to_carry
	|		[ANY]			L	jmp scanleft_for_double_char2

carry_1right:
	__		[.]		(SPEC)	L	ret-


dummy:
	__		[ANY]			R	ret

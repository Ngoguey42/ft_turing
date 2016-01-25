;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    0n1n.s                                             :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/25 15:06:49 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/25 17:41:55 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"0n1n"
	alphabet[10.ynzo]
	blank[.]

; O(Nlog(N)) algorithm
; deduced from Youtube hhp3 "Theory of Computation" "59/65" @6m30

; valid input === input of form {0*1*.}

checkinput:
	__		[0]			R	rep
	|		[1]			R	ni
	|		[.]			L	jmp rewind_empty_1absent_0absent
	|		[ANY]		R	jmp checkinput_invalid
	__		[1]			R	rep
	|		[.]			L	jmp rewind_empty_1absent_0absent
	|		[ANY]		R	jmp checkinput_invalid

cross_first_zero_occurrence: ; loop entry point
	__		[z]			R	rep
	|		[0]	(z)		R	jmp nocross_first_zero_occurrence
	|		[1]			E	jmp cross_first_one_occurrence
	|		[o]			R	jmp cross_first_one_occurrence
	|		[.]			L	jmp rewind_empty_1absent_0absent ; Might be a fail case

nocross_first_zero_occurrence:
	__		[z]			R	rep
	|		[0]			R	jmp cross_first_zero_occurrence
	|		[1]			E	jmp cross_first_one_occurrence
	|		[o]			R	jmp cross_first_one_occurrence
	|		[.]			L	jmp rewind_empty_1absent_0absent ; Fail case, anyway

cross_first_one_occurrence:
	__		[o]			R	rep
	|		[1]	(o)		R	jmp nocross_first_one_occurrence
	|		[.]			L	jmp rewind_empty_1absent_0absent

nocross_first_one_occurrence:
	__		[o]			R	rep
	|		[1]			R	jmp cross_first_one_occurrence
	|		[.]			L	jmp rewind_empty_1absent_0absent



; Rewind states:
; 	Parity:
; 		- empty
;		- odd
;		- even
;	Presences:
;	 	- 1absent_0absent
;	 	- 1present_0absent
;		- 1present_0present
;		- 1absent_0present	FAIL-CASE
;	 	-
;	 	-

rewind_empty_1absent_0absent: ;begin
	__		[1]			L	jmp rewind_odd_1present_0absent
	|		[oz]		L	rep
	|		[0]			L	jmp rewind__1absent_0present
	|		[.]			R	jmp restore_success

rewind_odd_1present_0absent:
	__		[1]			L	jmp rewind_even_1present_0absent
	|		[oz]		L	rep
	|		[0]			L	jmp rewind_even_1present_0present
	|		[.]			R	jmp restore_fail

rewind_even_1present_0absent:
	__		[1]			L	jmp rewind_odd_1present_0absent
	|		[oz]		L	rep
	|		[0]			L	jmp rewind_odd_1present_0present
	|		[.]			R	jmp restore_fail

rewind_even_1present_0present:
	__		[0]			L	jmp rewind_odd_1present_0present
	|		[oz]		L	rep
	|		[.]			R	jmp cross_first_zero_occurrence

rewind_odd_1present_0present:
	__		[0]			L	jmp rewind_even_1present_0present
	|		[oz]		L	rep
	|		[.]			R	jmp restore_fail

rewind__1absent_0present: ;FAIL CASE
	__		[0z]		L	rep
	|		[.]			R	jmp restore_fail


restore_success:
	__		[z]	(0)		R	rep
	|		[o]	(1)		R	rep
	|		[01]		R	rep
	|		[.]	(y)		R	halt

restore_fail:
	__		[z]	(0)		R	rep
	|		[o]	(1)		R	rep
	|		[01]		R	rep
	|		[.]	(n)		R	halt

checkinput_invalid:
	__		[ANY]		R		rep
	|		[.]	(n) 	R		halt

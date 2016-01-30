;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    0n1n.s                                             :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/25 15:06:49 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/30 13:49:44 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"0n1n"
	alphabet[10.ynzo]
	blank[.]

; O(Nlog(N)) algorithm
; deduced from Youtube hhp3 "Theory of Computation" "59/65" @6m30

; Step 1: -> Check input (goto fail OR goto Step 2)
; Step 2: <- [01] parity check (goto success OR goto fail OR goto Step 3)
; Step 3: -> Cross [01] odd occurrences (goto Step 2)

; valid input === input of form {0*1*.}

; STEP 1

checkinput:
	__		[0]			R	rep
	|		[1]			R	ni
	|		[.]			L	jmp rewind_pointless_none
	|		[ANY]		R	jmp checkinput_invalid
	__		[1]			R	rep
	|		[.]			L	jmp rewind_pointless_none
	|		[ANY]		R	jmp checkinput_invalid


; STEP 2

; Rewind states:
; 	Parity:
; 		- pointless
;		- odd
;		- even
;	Presences:
;	 	- none
;	 	- 1
;		- 01
;		- 0      FAIL-CASE

rewind_pointless_none:
	__		[1]			L	jmp rewind_odd_1
	|		[oz]		L	rep
	|		[0]			L	jmp rewind_pointless_0
	|		[.]			R	jmp restore_success

rewind_odd_1:
	__		[1]			L	jmp rewind_even_1
	|		[oz]		L	rep
	|		[0]			L	jmp rewind_even_01
	|		[.]			R	jmp restore_fail

rewind_even_1:
	__		[1]			L	jmp rewind_odd_1
	|		[oz]		L	rep
	|		[0]			L	jmp rewind_odd_01
	|		[.]			R	jmp restore_fail

rewind_even_01:
	__		[0]			L	jmp rewind_odd_01
	|		[oz]		L	rep
	|		[.]			R	jmp cross_first_zero_occurrence

rewind_odd_01:
	__		[0]			L	jmp rewind_even_01
	|		[oz]		L	rep
	|		[.]			R	jmp restore_fail

rewind_pointless_0: ; FAIL CASE
	__		[0z]		L	rep
	|		[.]			R	jmp restore_fail


; STEP 3

; Cross states:
; 	Current zone:
;		- zero
;		- one
;	Next action:
;		- cross
;		- nocross

cross_first_zero_occurrence: ; loop entry point
	__		[z]			R	rep
	|		[0]	(z)		R	jmp nocross_first_zero_occurrence
	|		[1]			E	jmp cross_first_one_occurrence
	|		[o]			R	jmp cross_first_one_occurrence
	|		[.]			L	jmp rewind_pointless_none ; Might be a fail case

nocross_first_zero_occurrence:
	__		[z]			R	rep
	|		[0]			R	jmp cross_first_zero_occurrence
	|		[1]			E	jmp cross_first_one_occurrence
	|		[o]			R	jmp cross_first_one_occurrence
	|		[.]			L	jmp rewind_pointless_none ; Fail case, anyway

cross_first_one_occurrence:
	__		[o]			R	rep
	|		[1]	(o)		R	jmp nocross_first_one_occurrence
	|		[.]			L	jmp rewind_pointless_none

nocross_first_one_occurrence:
	__		[o]			R	rep
	|		[1]			R	jmp cross_first_one_occurrence
	|		[.]			L	jmp rewind_pointless_none


; halting states
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
	__		[ANY]		R	rep
	|		[.]	(n) 	R	halt

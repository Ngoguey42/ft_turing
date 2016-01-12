;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    utm.s                                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/11 14:16:30 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/12 18:42:22 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; CFG for the tape at any moment

; S ::= States Registers Tape

; AlphabetChar ::= 		;Any char from the alphabet, but
; 			no blank char allowed in the original input(S)
; EPSILON ::=

; BinaryDigit ::= 0 | 1
; BinaryDigitSubs ::= 0 | 1 | a | b

; BinaryNumber ::= BinaryDigit BinaryNumber | BinaryDigit					;Not empty
; BinaryNumberSubs ::= BinaryDigitSubs BinaryNumberSubs | BinaryDigitSubs	;Not empty
; Flags1 = u | y | n
; Flags2 = + | - | =

; StateId ::= BinaryNumberSubs
; Action ::= BinaryDigit
; Write ::= AlphabetChar BinaryDigit
; Read ::= AlphabetChar BinaryDigit
; IsFinal ::= BinaryDigit

; Transition ::=	- StateId = Action Write Read Flags1
; Transitions ::=	Transition Transitions | EPSILON			;Can be empty
; State ::= 		+ Transitions = StateId = IsFinal Flags1
; States ::=		State States | State

; BinaryRegsLoop ::=	BinaryDigitSubs BinaryRegsLoop BinaryDigitSubs | =
; BinaryRegs ::=		BinaryDigitSubs BinaryRegsLoop BinaryDigitSubs

; Registers ::=		= BinaryRegs = AlphabetChar AlphabetChar

; TapeCharsLoop ::= EPSILON | Flags2 AlphabetChar TapeCharsLoop
; TapeChars ::= Flags2 AlphabetChar TapeCharsLoop		; Not empty
; Tape ::= = L 0 TapeChars R

	name"utm.s"
	alphabet[uyn+-=01ab.LR]
	blank[.]

; STEP 0 - MAIN
main_validations:
	__		[ANY]			E		call prepare_states ; validate(hard) (and prepare)states
	__		[=]				R		call reg_endr ; validate(soft) registers
	__		[L]				E		call tape_endr ; validate(soft) tape
	__		[R]				E		call tape_endl ; back to tape_endl
	__		[L]				L		call reg_endl ; back to reg_endl


; STEP 1 - MAIN
main_find_state: ; state loop beginning, db->breg loop beginning
	__		[=]				L		call state_searchl_firstu
	|		[n]				E		call state_searchl_firstu
	__		[u]				L		ni
	__		[01]			L		ni
	__		[=]				L		ni
	__		[ab]			L		rep
	|		[0]		(a)		R		call+ carry_to_breg
	|		[1]		(b)		R		call+ carry_to_breg
	|		[=]				R		jmp main_breg1_fully_loaded
	__		[ab]			L		rep
	|		[=]				E		jmp main_find_state
main_breg1_fully_loaded:
	__		[a]		(0)		R		rep
	|		[b]		(1)		R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[u]				R		call rskip_any_state
	__		[=]				R		ni
	__		[ab]	(0)		R		rep
	|		[01]			R		rep
	|		[=]				L		ni
main_breg_compare_char: ; breg char loop beginning
	__		[ab]			L		rep
	|		[0]		(a)		R		call+ compare_to_breg
	|		[1]		(b)		R		call+ compare_to_breg
	|		[=]				R		halt ; global equality, comparison over
	__		[=ab]			E		jmp main_breg_char_no_match ; char no match
	|		[01]			E		jmp main_breg_char_match ; char match

main_breg_char_match:
	__		[0]		(a)		L		ni
	|		[1]		(b)		L		ni
	__		[01]			L		rep
	|		[=]				L		jmp main_breg_compare_char
main_breg_char_no_match:
	__		[a]		(0)		R		rep
	|		[b]		(1)		R		rep
	|		[=]				L		ni
	__		[01]			L		rep
	|		[=]				L		ni
	__		[01ab]	(a)		L		rep
	|		[=]				L		call state_searchl_firstu
	__		[u]		(n)		E		jmp main_find_state


; STEP 2? - MAIN
main_check_final: spread
	__		[ANY]			L		halt ;tmp

; STEP - MAIN
main_find_trans:

; STEP - MAIN
main_write:

; STEP - MAIN
main_action:

; STEP - MAIN
main_headchar_to_reg:

; STEP - MAIN
main_changestate:




; HALT 1
main_success_subprogram_halt:
	__		[ANY]			L		halt
	
; HALT 2
main_error_no_transition:
	__		[ANY]			L		halt


; STEP 1 - FIND STATE PHASE
carry_to_breg:
	__		[ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[u]				R		call rskip_any_state
	__		[=]				R		ni
	__		[ab]			R		rep
	|		[01=]			L		ni
	__		[ab]	(SPEC)	L		ret-

compare_to_breg:
	__		[ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		rep
	|		[ab=]			L		ni
	__		[SPEC]			E		ret- ; if char match, ret without moving
	|		[ANY]			R		ret- ; if char do not match, ret from char to the right


; STEP 0 - INIT PHASE
prepare_states:
	__		[+]				E		call prepare_state ; Loop on each states
	|		[=]				E		ret                ; Loop on each states End
	__		[+=]			E		pi                 ; Loop on each states

prepare_state:
	__		[+]				R		ni
	__		[-]				E		call prepare_trans ; Loop on each trans
	|		[=]				R		jmp prepare_state~ ; Loop on each trans End
	__		[-=]			E		pi                 ; Loop on each trans
prepare_state~:
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[uyn]			R		ret

prepare_trans:
	__		[-]				R		ni ; (trans lbegin)
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[0]				R		jmp prepare_trans~
	|		[1]				L		ni; write blank to write
	__		[ANY]	(.)		R		ni; write blank to write
	__		[1]				R		ni; write blank to write
prepare_trans~:
	__		[ANY]			R		ni
	__		[0]				R		jmp prepare_trans~~
	|		[1]				L		ni; write blank to read
	__		[ANY]	(.)		R		ni; write blank to read
	__		[1]				R		ni; write blank to read
prepare_trans~~:
	__		[uyn]			R		ret










; STATES/TRANSITIONS LEFT MOVES
trans_nextl:
	__		[uyn]			L		ni ; (trans rbegin)
	|		[+]				E		ret; (transs lend) (state lbegin)
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[-]				L		ret ;leaves head in a similar configuration

lskip_any_trans:
	__		[+]				E		ret ; (transs lend) (state lbegin)
	|		[uyn]			E		call trans_nextl ; (trans rbegin)
	__		[uyn+]			E		jmp lskip_any_trans

state_nextl:
	__		[uyn]			L		ni ; (state rbegin)
	|		[.]				E		ret; (states lend)
	__		[01]			L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		call lskip_any_trans
	__		[+]				L		ret ;leaves head in a similar configuration

state_searchl_firstu: ; undefined if not found
	__		[u]				E		ret ; (state rbegin)
	|		[yn]			E		call state_nextl ; (state rbegin)
	__		[ANY]			E		jmp state_searchl_firstu


; STATES/TRANSITIONS RIGHT MOVES
trans_nextr:
	__		[-]				R		ni ; (trans lbegin)
	|		[=]				E		ret; (transs rend)
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[uyn]			R		ret ;leaves head in a similar configuration

rskip_any_trans:
	__		[=]				E		ret ; (transs rend)
	|		[-]				E		call trans_nextr ; (trans lbegin)
	__		[=-]			E		jmp rskip_any_trans

state_nextr:
	__		[+]				R		call rskip_any_trans ;(transs lend) (state lbegin)
	|		[=]				E		ret; (states rend)
	__		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[uyn]			R		ret;leaves head in a similar configuration

rskip_any_state:
	__		[=]				E		ret ;
	|		[+]				E		call state_nextr ;
	__		[=+]			E		jmp rskip_any_state

; REGISTERS MOVES
reg_endr:
	__		[01ab]			R		rep ; (regs beginl)
	|		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[ANY]			R		ni
	__		[ANY]			R		ret
reg_endl:
	__		[ANY]			L		ni
	__		[ANY]			L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				E		ret ; (regs endl)

; TAPE MOVES
tape_endr:
	__		[L+-=]			R		ni
	|		[R]				E		ret
	__		[ANY]			R		jmp tape_endr

tape_endl:
	__		[R+-=]			L		ni
	|		[L]				E		ret
	__		[ANY]			L		jmp tape_endl

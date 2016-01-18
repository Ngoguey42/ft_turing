;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    utm.s                                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/11 14:16:30 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/18 19:02:41 by ngoguey          ###   ########.fr        ;
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
	|		[=]				R		jmp main_find_trans ; global equality, numbers match
	__		[=ab]			E		jmp main_breg_char_no_match ; char no match, stop
	|		[01]			E		jmp main_breg_char_match ; char match, check next

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


; STEP 2 - MAIN
main_find_trans:
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[ANY]			R		ni
	__		[ANY]			E		call+ carry_readchar_to_statetrans
	__		[n]		(y)		L		jmp main_write

; STEP 3 - MAIN
main_write:
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[ANY]			R		call+ carry_writechar_to_head
	__		[=]				E		jmp main_action

; STEP 4 - MAIN
main_action:
	__		[=]				E		call tape_endl
	__		[L]				L		call reg_endl
	__		[=]				L		call state_searchl_firstu
	__		[u]				L		ni
	__		[0]				L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		call trans_searchl_firsty
	__		[y]				L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			R		call+ carry_head_action
	__		[0]		(-)		L		jmp main_action_left
	|		[1]		(+)		R		jmp main_action_right


main_action_left:
	__		[ANY]			L		ni
	__		[+]		(=)		R		jmp main_headchar_to_reg
	|		[L]		(=)		R		jmp main_action_left_expand

main_action_left_expand:
	__		[ANY]			L		halt ;IMPLEMENT/DEBUG main_action_left_expand


main_action_right:
	__		[ANY]			R		ni
	__		[-]		(=)		R		jmp main_headchar_to_reg
	|		[R]		(=)		R		jmp main_action_right_expand

main_action_right_expand:
	__		[.]				R		ni
	__		[.]		(R)		R		jmp main_headchar_to_reg


; STEP 5 - MAIN
main_headchar_to_reg:
	__		[ANY]			L		call+ carry_headchar_to_reg
	__		[ANY]			L		jmp main_changestate

; STEP 6 - MAIN
main_changestate:
	__		[=]				L		ni
	__		[ab]	(a)		L		rep
	|		[=]				L		ni
	__		[ab]	(a)		L		rep
	|		[=]				L		call state_searchl_firstu
	__		[u]				L		ni
	__		[0]				L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		call trans_searchl_firsty
	__		[y]				L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[=]				L		call cpy_nextstate_to_reg
	__		[-]				E		jmp main_cleanup

; STEP 7 - MAIN
main_cleanup:
	__		[-]				E		call cleanup_transitions
	__		[01]			R		rep
	|		[=]				R		ni
	__		[01]			R		call cleanup_states
	__		[=]				R		ni
	__		[a]				R		rep
	|		[=]				R		ni
	__		[a]		(0)		R		rep
	|		[01]			R		rep
	|		[=]				L		ni

	__		[01]			L		rep
	|		[=]				L		ni
	__		[a]				L		rep
	|		[=]				E		jmp main_find_state

	__		[ANY]			L		halt ;tmp

; HALT 1
success_subprogram_halt:
	__		[ANY]			L		halt

; HALT 2
error_no_transition:
	__		[ANY]			L		halt

; HALT 3
error_no_matchingstate:
	__		[ANY]			L		halt




; STEP 7 - CLEANUP
cleanup_states:
	__		[un]	(u)		R		call state_nextr
	__		[+]				L		jmp cleanup_states
	|		[=]				L		ni
	__		[un]	(u)		R		ret




cleanup_transitions:
	__		[-]				R		ni
	|		[=]				R		ret
	__		[a]		(0)		R		rep
	|		[b]		(1)		R		rep
	|		[01]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[yn]	(u)		R		jmp cleanup_transitions

; STEP 6 - COPY NEXT STATE TO REG
cpy_nextstate_to_reg:
	__		[ab]			L		rep
	|		[0]		(a)		R		call+ carry_nextstatechar_to_reg
	|		[1]		(b)		R		call+ carry_nextstatechar_to_reg
	|		[-]				E		ret
	__		[a]				L		rep
	|		[=]				L		ni
	__		[a]				L		rep
	|		[=]				L		call state_searchl_firstu
	__		[u]				L		ni
	__		[0]				L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		call trans_searchl_firsty
	__		[y]				L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[=]				L		jmp cpy_nextstate_to_reg

carry_nextstatechar_to_reg:
	__		[ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[y]				R		call rskip_any_trans
	__		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[0]				R		ni
	__		[u]				R		call rskip_any_state
	__		[=]				R		ni
	__		[a]				R		rep
	|		[=]				R		ni
	__		[a]				R		rep
	|		[01=]			L		ni
	__		[a]		(SPEC)	L		ret-
	__		[ANY]			L		halt

; STEP 5 - CARRY HEADCHAR TO REG
carry_headchar_to_reg:
	__		[=]				E		call tape_endl
	__		[L]				L		ni
	__		[ANY] 	(SPEC)	L		ret-

; STEP 4 - MOVE HEAD
carry_head_action:
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[y]				R		call rskip_any_trans
	__		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[0]				R		ni
	__		[u]				R		call rskip_any_state
	__		[=]				R		call reg_endr
	__		[L]				E		call tape_searchr_head
	__		[=]		(SPEC)	E		ret-

; STEP 3 - CARRY WRITE CHAR TO TAPE HEAD
carry_writechar_to_head:
	__		[01]			R		ni
	__		[ANY]			R		ni
	__		[01]			R		ni
	__		[y]				R		call rskip_any_trans
	__		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[0]				R		ni
	__		[u]				R		call rskip_any_state
	__		[=]				R		call reg_endr
	__		[L]				E		call tape_searchr_head
	__		[=]				R		ni
	__		[ANY]	(SPEC)	L		ret-

; STEP 2 - CARRY READ CHAR TO MATCHED STATE'S TRANSITIONS (AND CHECK FOR HALT)
carry_readchar_to_statetrans:
	__		[SPEC]			E		call reg_endl
	__		[=]				L		call state_searchl_firstu
	__		[u]				L		ni
	__		[0]				L		ni
	|		[1]				R		jmp success_subprogram_halt ;subprogram halt
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		call follow_transition_or_die
	__		[01]			R		ret-

follow_transition_or_die:
	__		[u]		(n)		L		ni
	|		[+]				R		jmp error_no_transition ;subprogram failed
	__		[01]			L		ni
	__		[SPEC]			R		ret ;read found
	|		[ANY]			L		ni
	__		[01]			L		ni
	__		[ANY]			L		ni
	__		[01]			L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[-]				L		jmp follow_transition_or_die







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

trans_searchl_firsty:
	__		[un]			E		call trans_nextl ; (trans rbegin)
	|		[y]				E		ret
	__		[uyn]			E		jmp trans_searchl_firsty


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
	|		[.]				E		jmp error_no_matchingstate
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

tape_searchr_head:
	__		[L+]			R		ni
	|		[=]				E		ret
	__		[ANY]			R		jmp tape_searchr_head


tape_endl:
	__		[R+-=]			L		ni
	|		[L]				E		ret
	__		[ANY]			L		jmp tape_endl

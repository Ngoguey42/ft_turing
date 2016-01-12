;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    utm.s                                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/11 14:16:30 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/12 14:10:14 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

; CFG for my UTM's tape

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

main:
	__		[ANY]			E		call prepare_states ; validate(hard) (and prepare)states
	__		[=]				R		call reg_endr ; validate(soft) registers
	__		[L]				E		call tape_endr ; validate(soft) tape
	__		[R]				E		call tape_endl ; back to endl
	__		[ANY]			L		halt

master_loop_after_action:



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










; STATES/TRANSITIONS RIGHT MOVES
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
	__		[ANY]			E		jmp lskip_any_trans

state_nextl:
	__		[uyn]			L		ni ; (state rbegin)
	|		[.]				E		ret; (states lend)
	__		[01]			L		ni
	__		[=]				L		ni
	__		[01ab]			L		rep
	|		[=]				L		call lskip_any_trans
	__		[+]				L		ret ;leaves head in a similar configuration

state_searchl_u: ; undefined if not found
	__		[u]				E		ret ; (state rbegin)
	|		[yn]			E		call state_nextl ; (state rbegin)
	__		[ANY]			E		jmp state_searchl_u


; STATES/TRANSITIONS LEFT MOVES
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
	__		[ANY]			E		jmp rskip_any_trans

state_nextr:
	__		[+]				R		call rskip_any_trans ;(transs lend) (state lbegin)
	|		[=]				E		ret; (states rend)
	__		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[01]			R		ni
	__		[uyn]			R		ret;leaves head in a similar configuration


; REGISTERS MOVES
reg_endr:
	__		[01ab]			R		rep ; (regs beginl)
	|		[=]				R		ni
	__		[01ab]			R		rep
	|		[=]				R		ni
	__		[ANY]			R		ni
	__		[ANY]			R		ret

; TAPE MOVES
tape_endr:
	__		[L+-=]			R		ni
	|		[R]				E		ret
	__		[ANY]			R		jmp tape_endr

tape_endl:
	__		[R+-=]			L		ni
	|		[L]				E		ret
	__		[ANY]			L		jmp tape_endl

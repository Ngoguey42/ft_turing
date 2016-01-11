;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    utm.s                                              :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2016/01/11 14:16:30 by ngoguey           #+#    #+#              ;
;    Updated: 2016/01/11 15:43:15 by ngoguey          ###   ########.fr        ;
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
; Flags2 = + | -

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

; TapeChars ::= EPSILON | Flags2 AlphabetChar TapeChars  		;Can be empty
; Tape ::= = TapeChars

	name"utm.s"
	alphabet[uyn+-=01ab.]
	blank[.]

main:
	__		[ANY]			L		call state_nextl
	__		[ANY]			L		call state_nextr
	__		[ANY]			L		halt

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

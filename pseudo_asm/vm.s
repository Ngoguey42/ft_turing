;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    vm.s                                               :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 11:12:22 by ngoguey           #+#    #+#              ;
;    Updated: 2015/12/27 12:43:12 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

is_state:
	init_state_begin				[+]		goto is_transi				R
	''								[=]		goto skip_buffer			R

is_transi:
	init_state_transi_begin			[1]		ni							R
	''								[=]		goto state_tail				R
	init_state_transi_nextstate		[1]		rep							R
	''								[=]		ni							R
	init_state_transi_action		[01]	ni							R
	init_state_transi_write			[ANY]	ni							R
	init_state_transi_read			[ANY]	ni							R
	init_state_transi_flag			[u]		goto is_transi				R

state_tail:
	init_state_id					[1]		rep							R
	''								[=]		ni							R
	init_state_final				[01]	ni							R
	init_state_flag					[u]		goto is_state				R

skip_buffer:
	init_buffer_breg1				[0]		rep							R
	''								[=]		ni							R
	init_buffer_breg2_part1			[1]		rep							R
	''								[0]		ni							R
	init_buffer_breg2_part2			[0]		rep							R
	''								[=]		ni							R
	init_buffer_creg1				[ANY]	ni							R
	init_buffer_creg2				[ANY]	ni							R


	init_tape_begin					[=]		ni							R
skip_char_right:
	init_tape_char_right			[ANY]	ni							R
	init_tape_spacer_right			[-]		goto skip_char_right		R
	''								[=]		ni							R
	init_tape_isblank				[.]		ni							L
	init_tape_skip_endspacer		[=]		ni							L
skip_char_left:
	init_tape_char_left				[ANY]	ni							L
	init_tape_spacer_left			[-]		goto skip_char_left			L
	''								[=]		ni							R

head_on_head:
	load_creg2_start				[ANY]	ni{fork}					L
load_creg2_skipspacer:
	load_creg2_{}_skipspacer		[=]		goto load_creg2_drop		L
	''								[+]		ni							L
	load_creg2_{}_skipchar			[ANY]	goto load_creg2_skipspacer	L
load_creg2_drop:
	load_creg2_{}_drop				[ANY]	ni							L ({})

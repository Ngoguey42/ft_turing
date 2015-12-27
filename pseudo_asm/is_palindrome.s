;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    is_palindrome.s                                    :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2015/12/27 12:43:53 by ngoguey           #+#    #+#              ;
;    Updated: 2015/12/27 12:59:37 by ngoguey          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

	name"is_palindrome"
	alphabet[.uyn+-=01]
	blank[.]

leftmost_char:
	save_char				[ANY]	ni						R	(.)
	''						[.]		goto success			R
	reach_end_{}			[ANY]	rep						R
	''						[.]		ni						L
	compare_chars_{}		[ANY]	goto fail				R
	''						[{}]	ni						L	(.)
	reach_begin				[ANY]	rep						L
	''						[.]		goto leftmost_char		R

fail:
	write_n					[ANY]	ni						R	(n)
	FINAL_FAIL

success:
	write_y					[ANY]	ni						R	(y)
	FINAL_SUCCESS
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    resolve.py                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 19:13:48 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/05 19:40:15 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


def compute_ANY_list(read_by_state, alphabet, spec):
	lst = []
	if spec != None:
		assert('SPEC' in read_by_state)
	for c in alphabet:
		if (c not in read_by_state):
			if not ('SPEC' in read_by_state and c == spec):
				lst.append(c)
	return lst


def rec(prog, state, hdr, spec):
	# hdr = stack_to_string(stack)
	name = "%s(s%d)" %(state.label, state.sid)
	fullname = hdr + name

	for read in state.reads:

		chars_read = []
		if read.reads[0] == 'SPEC':
			assert(spec != None)
			chars_read.append(spec)
		elif read.reads[0] == 'ANY':
			chars_read = compute_ANY_list(state.char_reads, prog.alphabet, spec)
		else:
			chars_read = read.reads[0]
		for char_read in chars_read:
			print char_read
		print


def resolve(prog):
	print
	startstate = prog.liststates[0]
	rec(prog, startstate, "", None)

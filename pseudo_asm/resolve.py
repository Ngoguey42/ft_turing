# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    resolve.py                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 19:13:48 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/06 13:03:16 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


def compute_ANY_list(read_by_state, alphabet, spec):
	lst = []
	if 'SPEC' in read_by_state:
		if spec == None:
			raise Exception("SPEC without specialization")
		return [x for x in alphabet if x not in read_by_state and x != spec]
	else:
		return [x for x in alphabet if x not in read_by_state]


def rec(prog, state, hdr, spec):
	name = "%s(s%d)" %(state.label, state.sid)
	fullname = hdr + name

	for read in state.reads:

		chars_read = []
		if read.reads[0] == 'SPEC':
			assert(spec != None)
			chars_read = [spec]
		elif read.reads[0] == 'ANY':
			chars_read = compute_ANY_list(state.char_reads, prog.alphabet, spec)
		else:
			chars_read = read.reads
		for char_read in chars_read:
			print "[", char_read, "]"
		print


def resolve(prog):
	print
	startstate = prog.lst_st[0]
	rec(prog, startstate, "", None)

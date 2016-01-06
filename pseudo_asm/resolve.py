# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    resolve.py                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 19:13:48 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/06 13:17:39 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

def callstack_to_string(callstack):
	string = ""
	for call in callstack:
		if call[2] != None:
			string += "%s(s%d)<%s>" %(call[0], call[1], call[3])
		else:
			string += "%s(s%d)" %(call[0], call[1])


def compute_ANY_list(read_by_state, alphabet, spec):
	lst = []
	if 'SPEC' in read_by_state:
		if spec == None:
			raise Exception("SPEC without specialization")
		return [x for x in alphabet if x not in read_by_state and x != spec]
	else:
		return [x for x in alphabet if x not in read_by_state]


def rec(prog, callstack):
	top_st = prog.dic_st[(callstack[-1][0], callstack[-1][1])]
	top_spec = callstack[-1][2]
	# transitions = []

	# for read in top_st.reads:

	# 	chars_read = []
	# 	if read.reads[0] == 'SPEC':
	# 		assert(spec != None)
	# 		chars_read = [spec]
	# 	elif read.reads[0] == 'ANY':
	# 		chars_read = compute_ANY_list(state.char_reads, prog.alphabet, spec)
	# 	else:
	# 		chars_read = read.reads
	# 	for char_read in chars_read:
	# 		print "[", char_read, "]"
		# print


def resolve(prog):
	print
	fst = prog.lst_st[0]
	rec(prog, [(fst.label, fst.sid, None)])

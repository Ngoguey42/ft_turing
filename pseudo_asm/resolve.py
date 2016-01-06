# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    resolve.py                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 19:13:48 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/06 16:05:40 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

def call_to_string(call):
	if call[2] != None:
		return "%s(s%d)<%s>" %(call[0], call[1], call[3])
	else:
		return "%s(s%d)" %(call[0], call[1])

def callstack_to_string(callstack):
	string = ""
	for call in callstack:
		string += call_to_string(call)
	return string

def compute_ANY_list(read_by_state, alphabet, spec):
	lst = []
	if 'SPEC' in read_by_state:
		return [x for x in alphabet if x not in read_by_state and x != spec]
	else:
		return [x for x in alphabet if x not in read_by_state]

def compute_read_chars(lst_chars_read, set_alphabet, set_state_read, spec):
	if 'SPEC' in set_state_read and spec == None:
		raise Exception("SPEC without specialization")
	if lst_chars_read[0] == 'ANY':
		return compute_ANY_list(set_state_read, set_alphabet, spec)
	elif lst_chars_read[0] == 'SPEC':
		return [spec]
	else:
		return lst_chars_read

def compute_next_call(prog, top_st, callstack, read):
	if read.nexts[0] == 'rep':
		return callstack[-1]
	elif read.nexts[0] == 'ni':
		if len(prog.lst_st) <= top_st.gid + 1:
			raise Exception('NextInstruction to end of file')
		next_st = prog.lst_st[top_st.gid + 1]
		return (next_st.label, next_st.sid, None)
	elif read.nexts[0] == 'jmp':
		next_st = prog.dic_st[(read.nexts[1], 1)]
		return (next_st.label, next_st.sid, None)
	elif read.nexts[0] == 'halt':
		return None
	# elif read.nexts[0] == '':


def rec(prog, callstack, spec):
	top_st = prog.dic_st[(callstack[-1][0], callstack[-1][1])]
	top_spec = callstack[-1][2]
	# call_str = call_to_string(callstack[-1])
	callstack_str = callstack_to_string(callstack)
	transi = []

	if callstack_str in prog.set_resolved_states:
		return
	prog.set_resolved_states.add(callstack_str)
	print '\n', 'DOING:', callstack_str
	# print prog.set_resolved_states
	for read in top_st.lst_reads:
		read_chars = compute_read_chars(
			read.reads, prog.alphabet, top_st.set_readchars, spec)
		next_call = compute_next_call(prog, top_st, callstack, read)
		next_call_str = None #tmp
		if next_call != None: #tmp
			next_call_str = call_to_string(next_call)  #tmp
		else:
			next_call_str = "HALT"
		print "callstack:", callstack_str, "reads:", read_chars, "next_call:", next_call
		for c in read_chars:
			write = read.write if read.write != None else c
			print c, "->", write
			transi.append((c, write, read.action, next_call_str))
		tmp_callstack = callstack
		if next_call == None: #tmp
			continue  #tmp
		tmp_callstack[-1] = next_call
		rec(prog, tmp_callstack, spec)

	prog.dic_st_transi[callstack_str] = transi




def resolve(prog):
	print
	fst = prog.lst_st[0]
	rec(prog, [(fst.label, fst.sid, None)], None)
	assert('HALT' not in prog.set_resolved_states)
	prog.set_resolved_states.add('HALT')
	print "done:", prog.set_resolved_states
	print prog.dic_st_transi

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    resolve.py                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 19:13:48 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/12 12:17:14 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

def call_to_string(call):
	if call[2] != None:
		return " <%s> %s(s%d)" %(call[2], call[0], call[1])
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

def compute_next_call(prog, top_st, callstack, read, rchar):
	if read.nexts[0] == 'rep':
		return callstack[-1]
	elif read.nexts[0] == 'ni':
		if len(prog.lst_st) <= top_st.gid + 1:
			raise Exception('NextInstruction to end of file')
		next_st = prog.lst_st[top_st.gid + 1]
		return (next_st.label, next_st.sid, callstack[-1][2])
	elif read.nexts[0] == 'pi':
		if top_st.gid == 0:
			raise Exception('PrevInstruction to begin of file')
		next_st = prog.lst_st[top_st.gid - 1]
		return (next_st.label, next_st.sid, callstack[-1][2])
	elif read.nexts[0] == 'jmp':
		next_st = prog.dic_st[(read.nexts[1], 1)]
		return (next_st.label, next_st.sid, callstack[-1][2])
	elif read.nexts[0] == 'halt':
		return None
	elif read.nexts[0] == 'call+':
		next_st = prog.dic_st[(read.nexts[1], 1)]
		return (next_st.label, next_st.sid, rchar)
	elif read.nexts[0] == 'ret-':
		calling_st = prog.dic_st[(callstack[-2][0], callstack[-2][1])]
		next_st = prog.lst_st[calling_st.gid + 1]
		return (next_st.label, next_st.sid, callstack[-2][2])
	elif read.nexts[0] == 'call':
		next_st = prog.dic_st[(read.nexts[1], 1)]
		return (next_st.label, next_st.sid, callstack[-1][2])
	elif read.nexts[0] == 'ret':
		calling_st = prog.dic_st[(callstack[-2][0], callstack[-2][1])]
		next_st = prog.lst_st[calling_st.gid + 1]
		return (next_st.label, next_st.sid, callstack[-1][2])


def rec(prog, callstack, spec):
	top_st = prog.dic_st[(callstack[-1][0], callstack[-1][1])]
	callstack_str = callstack_to_string(callstack)
	transi = []

 	if callstack_str in prog.set_resolved_states:
		return
	prog.set_resolved_states.add(callstack_str)
	for read in top_st.lst_reads:
		read_chars = compute_read_chars(
			read.reads, prog.alphabet, top_st.set_readchars, spec)
		is_epsilon = read.action == 'E'
		action = {'L': 'LEFT', 'R': 'RIGHT'}['L' if is_epsilon else read.action]
		suffix = 'Adjust' if is_epsilon else ''
		for c in read_chars:

			def get_write():
				if read.write == None:
					return c
				elif read.write == 'SPEC':
					assert(spec != None) # no spec when writing spec
					return spec
				else:
					return read.write
			write = get_write()
			next_call = compute_next_call(prog, top_st, callstack, read, c)
			tmp_callstack = list(callstack)
			tmp_spec = -1
			if read.nexts[0] == 'halt':
				if is_epsilon:
					raise Exception('Epsilon action before halt not allowed')
				transi.append((c, write, action, 'HALT'))
				continue
			elif read.nexts[0] == 'call+':
				if spec != None:
					raise Exception('Multiple specialization not allowed')
				tmp_callstack.append(next_call)
				tmp_spec = next_call[2]
			elif read.nexts[0] == 'ret-':
				if spec == None:
					raise Exception('ret- without specialization not allowed')
				del tmp_callstack[-1]
				tmp_callstack[-1] = next_call
				tmp_spec = None
			elif read.nexts[0] == 'call':
				tmp_callstack.append(next_call)
				tmp_spec = spec
			elif read.nexts[0] == 'ret':
				del tmp_callstack[-1]
				tmp_callstack[-1] = next_call
				tmp_spec = spec
			else:
				tmp_callstack[-1] = next_call
				tmp_spec = spec
			tmp_callstack_str = callstack_to_string(tmp_callstack)
			transi.append((c, write, action, tmp_callstack_str + suffix))
			if is_epsilon:
				prog.set_required_pre.add(tmp_callstack_str)
			rec(prog, tmp_callstack, tmp_spec)

	prog.dic_st_transi[callstack_str] = transi
	return



def resolve(prog):
	print
	fst = prog.lst_st[0]
	rec(prog, [(fst.label, fst.sid, None)], None)
	assert('HALT' not in prog.set_resolved_states)
	prog.set_resolved_states.add('HALT')
	print "done:", prog.set_resolved_states
	print prog.dic_st_transi

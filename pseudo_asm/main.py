# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    main.py                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 12:19:49 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/05 16:46:24 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

from tokenize_arg1 import get_tokens

"""

state (
	self.label : string
	self.sid : int (1+)

	self.final : bool
	self.rawreads : tuple list
	self.read : (string * transi) hashmap
   	read ( ANY | SPEC | CHARS * chars)

		write ( NONE | SOME char )
		action ( L | R | E )
		next (
			rep						goto self
			ni						goto next
			halt					not a transition
			ret						goto next of parent
			ret-					goto next of parent
			jmp IDENTIFIER			goto first of label
			call IDENTIFIER			goto first of label
		   	call+ IDENTIFIER		goto first of label
)





callstack (sgroup, sid, specifier)

"""
class State:
	def __init__(self, label, sid):
		self.label = label
		self.sid = sid
		self.rawreads = []
		self.reads = None
		self.final = None

	def addrawread(self, rawread):
		self.rawreads.append(rawread)



class Prog:
	def __init__(self, tokens):
		self.save_name(tokens.pop(0))
		self.save_alpha(tokens.pop(0))
		self.save_blank(tokens.pop(0))
		self.generate_states(tokens)

	def save_name(self, tk):
		assert(tk[0] == 'name')
		self.name = tk[1];

	def save_alpha(self, tk):
		assert(tk[0] == 'alphabet')
		s = set(tk[1])
		assert(len(tk[1]) == len(s))
		self.alphabet = s;

	def save_blank(self, tk):
		assert(tk[0] == 'blank')
		self.blank = tk[1]

	def generate_states(self, tks):
		ll = []
		ls = []
		sid = -1
		curl = None
		curs = None
		for tk in tks:
			if tk[0] == 'label':
				curl = tk[1]		#label related
				ll.append(curl)		#label related
				sid = 0				#label related
				if curs != None:	#curstate related
					ls.append(curs)	#curstate related
			elif tk[0] == 'statestrt':
				if curs != None:		#curstate related
					ls.append(curs)		#curstate related
				assert(curl != None)	#label related
				sid += 1				#label related
				curs = State(curl, sid)
				curs.addrawread(tk[1])
			elif tk[0] == 'stateor':
				assert(curs != None)
				curs.addrawread(tk[1])
			else:
				assert(false)

		if curs != None:        #curstate related
			ls.append(curs)     #curstate related
		sl = set(ll)
		assert(len(sl) == len(ll))
		self.setlabels = sl
		self.liststates = ls


if __name__ == "__main__":
	tk = get_tokens()
	p = Prog(tk)
	print p.name
	print p.alphabet
	print p.blank
	print p

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    main.py                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 12:19:49 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/06 13:05:45 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

from tokenize_arg1 import get_tokens
from resolve import resolve
import re

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

(call(name, has_specifier)) stack
"""

class Read:
	def __init__(self, tup, setlabels):
		if tup[0] == 'ANY' or tup[0] == 'SPEC':
			self.reads = [tup[0]]
		else:
			self.reads = map(lambda x:x, tup[0])
		self.write = tup[1]
		self.action = tup[2]
		self.nexts = tuple(re.split('\s+', tup[3]))
		assert(len(self.nexts) <= 2)
		if len(self.nexts) == 2 and not self.nexts[1] in setlabels:
			raise Exception("missing label %s" %(self.nexts[1]))

	def __str__(self):
		return "%s (%s) %s %s" %(self.reads, str(self.write),
								 self.action, self.nexts)

class State:
	def __init__(self, label, sid):
		self.label = label
		self.sid = sid
		self.rawreads = []
		self.char_reads = None
		self.reads = None
		self.final = None
		self.used = None

	def __str__(self):
		return "%s(s%d) %s %s" %(self.label, self.sid, self.char_reads
								 , map(str, self.reads))

	def addrawread(self, rawread):
		self.rawreads.append(rawread)

	def buildinternal(self, setlabels, alphabet):
		assert(len(self.rawreads) > 0)
		rset = set()
		nset = set()
		rcount = 0
		for rawread in self.rawreads:
			nset.add(rawread[3])
			if rawread[0] == 'ANY':
				rcount += 1
				rset.add('ANY')
			elif rawread[0] == 'SPEC':
				rcount += 1
				rset.add('SPEC')
			else:
				rcount += len(rawread[0])
				rset = rset | set(map(lambda x:x, rawread[0]))
		assert(rcount == len(rset))	#reads uniqueness
		if 'halt' in nset:
			assert(len(nset) == 1)	#only halts when halt present
		self.char_reads = frozenset(rset)
		self.reads = map(lambda x:Read(x, setlabels), self.rawreads)
		del self.rawreads



class Prog:
	def __init__(self, tokens):
		self.name = None
		self.alpha = None
		self.blank = None

		self.lst_lb = []
		self.set_lb = None
		self.lst_st = []
		self.dic_st = dict()

		self.stid = -1
		self.cur_lb = None
		self.cur_st = None

		self.save_name(tokens.pop(0))
		self.save_alpha(tokens.pop(0))
		self.save_blank(tokens.pop(0))
		self.generate_states(tokens)

		del self.stid
		del self.cur_lb
		del self.cur_st

	def save_name(self, tk):
		assert(tk[0] == 'name')
		self.name = tk[1];

	def save_alpha(self, tk):
		assert(tk[0] == 'alphabet')
		s = set(tk[1])
		assert(len(tk[1]) == len(s))
		self.alphabet = frozenset(s);

	def save_blank(self, tk):
		assert(tk[0] == 'blank')
		self.blank = tk[1]


	def generate_states(self, tks):
		for tk in tks:
			if tk[0] == 'label':
				self.cur_lb = tk[1]
				self.lst_lb.append(tk[1])
				self.stid = 0
			elif tk[0] == 'statestrt':
				assert(self.cur_lb != None)
				self.stid += 1
				self.cur_st = State(self.cur_lb, self.stid)
				self.cur_st.addrawread(tk[1])
				self.dic_st[(self.cur_lb, self.stid)] = self.cur_st
				self.lst_st.append(self.cur_st)
			elif tk[0] == 'stateor':
				assert(self.cur_st != None)
				self.cur_st.addrawread(tk[1])
			else:
				assert(false)

		self.set_lb = frozenset(self.lst_lb)
		assert(len(self.set_lb) == len(self.lst_lb)) #no duplicates in labels
		assert(len(self.lst_st) > 0) #minimum 1 state
		for s in self.lst_st:
			s.buildinternal(self.set_lb, self.alphabet)


if __name__ == "__main__":
	tk = get_tokens()
	p = Prog(tk)
	print p.name
	print p.alphabet
	print p.blank
	print p.set_lb
	for st in p.lst_st:
		print str(st)
	resolve(p)

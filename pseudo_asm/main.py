# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    main.py                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 12:19:49 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/06 16:24:35 by ngoguey          ###   ########.fr        #
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
	def __init__(self, label, sid, gid):
		self.label = label
		self.sid = sid
		self.gid = gid
		self.set_readchars = None
		self.lst_reads = None
		self.final = None

		self.rawreads = []

	def __str__(self):
		return "%s(s%d) %s %s" %(self.label, self.sid, self.set_readchars
								 , map(str, self.lst_reads))

	def addrawread(self, rawread):
		self.rawreads.append(rawread)

	def buildinternal(self, setlabels, alphabet):
		assert(len(self.rawreads) > 0) #useless assert
		set_readchars = set()
		set_nexts = set()
		count_reads = 0
		for rawread in self.rawreads:
			set_nexts.add(rawread[3])
			if rawread[0] == 'ANY':
				count_reads += 1
				set_readchars.add('ANY')
			elif rawread[0] == 'SPEC':
				count_reads += 1
				set_readchars.add('SPEC')
			else:
				count_reads += len(rawread[0])
				set_readchars |= set(map(lambda x:x, rawread[0]))
		assert(count_reads == len(set_readchars))	#reads uniqueness
		if 'halt' in set_nexts:
			self.final = True
			assert(len(set_nexts) == 1)	#only halts when halt present
		else:
			self.final = False
		self.set_readchars = frozenset(set_readchars)
		self.lst_reads = map(lambda x:Read(x, setlabels), self.rawreads)
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
		self.dic_st_transi = dict()
		self.set_resolved_states = set()

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
		gid = 0
		for tk in tks:
			if tk[0] == 'label':
				self.cur_lb = tk[1]
				self.lst_lb.append(tk[1])
				self.stid = 0
			elif tk[0] == 'statestrt':
				assert(self.cur_lb != None)
				self.stid += 1
				self.cur_st = State(self.cur_lb, self.stid, gid)
				gid += 1
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

	def tojson(self):
		string = "{\n"
		string += '\t"name"\t\t: "%s",\n' %(self.name)

		string += '\t"alphabet"\t: [ '
		for c in self.alphabet:
			string += '"%s", ' %(c)
		string += '],\n'

		string += '\t"states"\t: [ '
		for s in self.set_resolved_states:
			string += '"%s", ' %(s)
		string += '],\n'

		string += '\t"initial"\t: "%s(s%d)",\n' %(self.lst_st[0].label, self.lst_st[0].sid)

		string += '\t"finals"\t: [ "HALT" ],\n'
		string += '\n'
		string += '\t"transitions"\t: {\n'

		for k, v in self.dic_st_transi.iteritems():
			string += '\t\t"%s": [\n' %(k)
			for tr in v:
				fmt = '\t\t\t{ "read" : "%s", "to_state": "%s", "write": "%s", "action": "%s"},\n'
				string += fmt %(tr[0], tr[3], tr[1], tr[2])
				# %(tr[0], tr[1], tr[2], tr[3])
			string += '\t\t]\n'

		string += '\t}\n'
		string += "}\n"
		print string


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
	p.tojson()

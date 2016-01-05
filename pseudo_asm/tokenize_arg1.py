# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tokenize_arg1.py                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/05 14:28:53 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/05 15:19:30 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

from sys import argv
import re

def kill_comments(line):
	return line.split(';')[0]

def line_empty(line):
	if re.match("^\s*$", line) == None:
		return False
	else:
		return True

read = "\[(.+)\]"
write = "(?:\((.+)\)\s+)?"
action = "(R|E|L)"
nexts = "(rep|ni|halt|jmp\s+\S+|call\s+\S+|call\+\s+\S+|ret|ret\-)"
sp = "\s+"

pattern1 = "^\s*__\s+" + read + sp + write + action + sp + nexts + "\s*$"
pattern2 = "^\s*\|\s+" + read + sp + write + action + sp + nexts + "\s*$"

def parse_line(line):
	name = re.match("^\s*name\"(.+)\"\s*$", line)
	if name != None:
		return ('name', name.group(1))
	alpha = re.match("^\s*alphabet\[(.+)\]\s*$", line)
	if alpha != None:
		return ('alphabet', alpha.group(1))
	blank = re.match("^\s*blank\[(.)\]\s*$", line)
	if blank != None:
		return ('blank', blank.group(1))
	label = re.match("^\s*(.*):\s*$", line)
	if label != None:
		return ('label', label.group(1))
	statestrt = re.match(pattern1, line)
	if statestrt != None:
		return ('statestrt', statestrt.group(1, 2, 3, 4))
	stateor = re.match(pattern2, line)
	if stateor != None:
		return ('stateor', stateor.group(1, 2, 3, 4))
	raise Exception('Bad line: ' + line)


def get_tokens():
	lines = open(argv[1], "r").read().split('\n')
	lines = map(kill_comments, lines)
	lines = [parse_line(x) for x in lines if not line_empty(x)]
	for x in lines:
		print x
	return lines

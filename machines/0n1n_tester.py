# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    0n1n_tester.py                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/25 17:43:52 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/25 18:43:39 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

import os
import re
import sys

#testing all strings with 0/1 in input
alphabet = ['1', '0']
max_depth = 8

def rec(input_, depth):
	cmd = """
rm -rf tmpinput tmperr;
../ft_turing -s 0n1n.json """ + '"' + input_ + '"' +  """ 2>tmperr | tail -n 1 1>tmpinput;
cat tmperr tmpinput;
[[ -s tmpinput ]] && (cat tmpinput | grep y 1>/dev/null)"""
	ret = os.system(cmd)
	sys.stdout.flush()
	grps = re.match("^(0*)(1*)$", input_)
	print "ret:", ret, 'input:"' + input_ + '"'
	sys.stdout.flush()
	if grps == None:
		assert(ret != 0)
	elif len(grps.group(1)) != len(grps.group(2)):
		assert(ret != 0)
	else:
		assert(ret == 0)
	if depth <= max_depth:
		for letter in alphabet:
			rec(input_ + letter, depth + 1)

if __name__ == "__main__":
	rec("", 1)
	os.system("rm -rf tmpinput tmperr")

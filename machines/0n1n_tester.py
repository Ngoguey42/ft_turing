# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    0n1n_tester.py                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/01/25 17:43:52 by ngoguey           #+#    #+#              #
#    Updated: 2016/01/25 17:53:17 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

import os

# test all strings with "valid input"

if __name__ == "__main__":
	max_ = 15

	for i0 in range(0, max_):
		for i1 in range(0, max_):
			input_ = ("0" * i0) + ("1" * i1)
			cmd = "../ft_turing 0n1n.json \"" + input_ + "\" 2>/dev/null | tail -n 1 | grep y"
			ret = os.system(cmd)
			if i0 != i1:
				assert(ret != 0)
			else:
				assert(ret == 0)

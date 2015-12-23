# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fbuoro <fbuoro@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/06/24 10:51:44 by fbuoro            #+#    #+#              #
#    Updated: 2015/12/23 14:49:17 by fbuoro           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = pouet
SRCS = nodep.ml req1_a.ml req1_b.ml req3.ml main.ml
INTS = nodep.mli req1_b.mli
CAMLC = ocamlc
CAMLOPT = ocamlopt
CAMLDEP = ocamldep
LIBS = -thread -package core,yojson

all: $(NAME)

$(NAME): opt byt
	@ln -sf $(NAME).byt $(NAME)

opt: $(NAME).opt
byt: $(NAME).byt

OBJS = $(SRCS:.ml=.cmo)
OPTOBJS = $(SRCS:.ml=.cmx)
OBJINTS = $(INTS:.mli=.cmi)

$(NAME).byt: $(OBJINTS) $(OBJS)
	ocamlfind ocamlc -g -linkpkg $(LIBS) -o $(NAME).byt $(OBJS)

$(NAME).opt: $(OBJINTS) $(OPTOBJS)
	ocamlfind ocamlopt -g -linkpkg $(LIBS) -o $(NAME).opt $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	ocamlfind ocamlc $(LIBS) -c $<

.mli.cmi:
	ocamlfind ocamlc $(LIBS) $< -o $@

.ml.cmx:
	ocamlfind ocamlopt $(LIBS) -I . -c $<

clean:
	rm -f *.cm[iox] *.o
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME)
	rm -f $(NAME).opt
	rm -f $(NAME).byt

re: fclean all

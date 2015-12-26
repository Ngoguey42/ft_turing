# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fbuoro <fbuoro@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/06/24 10:51:44 by fbuoro            #+#    #+#              #
#    Updated: 2015/12/26 14:18:57 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = ft_turing

SRCS = Action.ml MonadicTry.ml YojsonTreeMatcher.ml
INTS = Action.mli MonadicTry.mli YojsonTreeMatcher.mli

SRCS += ProgramDataTmp.ml YojsonTree.ml ProgramData.ml
INTS += ProgramDataTmp.mli YojsonTree.mli

SRCS += Tape.ml LoopGuard.ml Arguments.ml Main.ml

CAMLC = ocamlc
CAMLOPT = ocamlopt
# CAMLDEP = ocamldep
FLAGS = -thread -package core,yojson
LD_FLAGS = -g -linkpkg

all: $(NAME)

$(NAME): opt byt
	@ln -sf $(NAME).opt $(NAME)

opt: $(NAME).opt
byt: $(NAME).byt

OBJS = $(SRCS:.ml=.cmo)
OPTOBJS = $(SRCS:.ml=.cmx)
CMI = $(INTS:.mli=.cmi)

$(NAME).byt: $(CMI) $(OBJS)
	ocamlfind ocamlc $(LD_FLAGS) $(FLAGS) -o $(NAME).byt $(OBJS)

$(NAME).opt: $(CMI) $(OPTOBJS)
	ocamlfind ocamlopt $(LD_FLAGS) $(FLAGS) -o $(NAME).opt $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	ocamlfind ocamlc $(FLAGS) -I . -c $<

.mli.cmi:
	ocamlfind ocamlc $(FLAGS) $< -o $@

.ml.cmx:
	ocamlfind ocamlopt $(FLAGS) -I . -c $<

clean:
	rm -f *.cm[iox] *.o
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME)
	rm -f $(NAME).opt
	rm -f $(NAME).byt

re: fclean all

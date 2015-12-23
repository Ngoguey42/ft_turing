# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fbuoro <fbuoro@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/06/24 10:51:44 by fbuoro            #+#    #+#              #
#    Updated: 2015/12/23 15:37:11 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = ft_turing
SRCS = Action.ml MonadicTry.ml YojsonTreeMatcher.ml
SRCS += ProgramDataTmp.ml ProgramData.ml ProgramCreator.ml
SRCS += Main.ml
INTS = MonadicTry.mli Action.mli ProgramDataTmp.mli YojsonTreeMatcher.mli
INTS += ProgramCreator.mli
CAMLC = ocamlc
CAMLOPT = ocamlopt
CAMLDEP = ocamldep
LIBS = -thread -package core,yojson

all: $(NAME)

$(NAME): opt byt
	@ln -sf $(NAME).opt $(NAME)

opt: $(NAME).opt
byt: $(NAME).byt

OBJS = $(SRCS:.ml=.cmo)
OPTOBJS = $(SRCS:.ml=.cmx)
CMI = $(INTS:.mli=.cmi)

$(NAME).byt: $(CMI) $(OBJS)
	ocamlfind ocamlc -g -linkpkg $(LIBS) -o $(NAME).byt $(OBJS)

$(NAME).opt: $(CMI) $(OPTOBJS)
	ocamlfind ocamlopt -g -linkpkg $(LIBS) -o $(NAME).opt $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	ocamlfind ocamlc $(LIBS) -I . -c $<

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

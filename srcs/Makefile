# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fbuoro <fbuoro@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/06/24 10:51:44 by fbuoro            #+#    #+#              #
#    Updated: 2015/12/23 14:19:19 by fbuoro           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = ft_turing
SRCS = ProgramData/ProgramData.ml 
SRCS += Tape/Tape.ml
SRCS += YojsonParser/YojsonParser.ml
SRCS += LoopGuardV2/LoopGuard.ml
CAMLC = ocamlc
CAMLOPT = ocamlopt
CAMLDEP = ocamldep
LIBS = -linkpkg -thread -package core,yojson

all: $(NAME)

$(NAME): opt byt
	@ln -sf $(NAME).byt $(NAME)

opt: $(NAME).opt
byt: $(NAME).byt

OBJS = $(SRCS:.ml=.cmo)
OPTOBJS = $(SRCS:.ml=.cmx)

$(NAME).byt:  $(OBJS)
	ocamlfind ocamlc -g $(LIBS) -o $(NAME).byt $(OBJS)

$(NAME).opt: $(OPTOBJS)
	ocamlfind ocamlopt -g $(LIBS) -o $(NAME).opt $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	ocamlfind ocamlc $(LIBS) -c $<

.mli.cmi:
	$(CAMLC) -c $<

.ml.cmx:
	ocamlfind ocamlopt $(LIBS) -c $<

clean:
	rm -f *.cm[iox]
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME)
	rm -f $(NAME).opt
	rm -f $(NAME).byt

re: fclean all

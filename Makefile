# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fbuoro <fbuoro@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/06/24 10:51:44 by fbuoro            #+#    #+#              #
#    Updated: 2016/02/01 16:13:23 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = ft_turing

SRCSFILES = Action.ml MonadicTry.ml YojsonTreeMatcher.ml
INTSFILES = Action.mli MonadicTry.mli YojsonTreeMatcher.mli

SRCSFILES += ProgramDataTmp.ml YojsonTree.ml ProgramData.ml
INTSFILES += ProgramDataTmp.mli YojsonTree.mli

SRCSFILES += Tape.ml LoopGuard.ml
SRCSFILES += Convert.ml Verifier.ml Complexity.ml
SRCSFILES += Arguments.ml Main.ml


SRCDIR = ./srcs

CAMLC = ocamlc
CAMLOPT = ocamlopt

GNUPLOT = -I ./gnuplot-ocaml/_build/lib
LD_GNUPLOT = $(GNUPLOT) gnuplot.cmxa

FLAGS = $(GNUPLOT) -thread -package core,yojson

LD_FLAGS = $(LD_GNUPLOT) -linkpkg
LD_FLAGS_BYT = $(LD_FLAGS:.cmxa=.cma)
LD_FLAGS_OPT = $(LD_FLAGS)

all: $(NAME)

$(NAME): opt byt
	@ln -sf $(NAME).opt $(NAME)

opt: $(NAME).opt
byt: $(NAME).byt

SRCS = $(addprefix $(SRCDIR)/,$(SRCSFILES))
INTS = $(addprefix $(SRCDIR)/,$(INTSFILES))

OBJS = $(SRCS:.ml=.cmo)
OPTOBJS = $(SRCS:.ml=.cmx)
CMI = $(INTS:.mli=.cmi)




$(NAME).byt: $(CMI) $(OBJS)
	ocamlfind ocamlc $(LD_FLAGS_BYT) $(FLAGS) -o $(NAME).byt $(OBJS)

$(NAME).opt: $(CMI) $(OPTOBJS)
	ocamlfind ocamlopt $(LD_FLAGS_OPT) $(FLAGS) -o $(NAME).opt $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	ocamlfind ocamlc $(FLAGS) -I $(SRCDIR) -c $<

.mli.cmi:
	ocamlfind ocamlc $(FLAGS) -I $(SRCDIR) $< -o $@

.ml.cmx:
	ocamlfind ocamlopt $(FLAGS) -I $(SRCDIR) -c $<

clean:
	rm -f $(SRCDIR)/*.cm[iox] $(SRCDIR)/*.o
	rm -f $(SRCDIR)/$(NAME).o

fclean: clean
	rm -f $(NAME)
	rm -f $(NAME).opt
	rm -f $(NAME).byt

install_libs: #with a working brew on macos
	type opam >/dev/null ||\
		(brew install opam &&\
		opam init -n &&\
		(~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true) &&\
		eval `opam config env` &&\
		opam switch 4.02.3 &&\
		(~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true) &&\
		eval `opam config env`\
		)
	ls ~/.opam/4.02.3/lib/core >/dev/null || opam install -y core
	ls ~/.opam/4.02.3/lib/yojson >/dev/null || opam install -y yojson
	type ocamlfind >/dev/null || opam install -y ocamlfind
	type gnuplot >/dev/null || brew install gnuplot
	ls ./gnuplot-ocaml >/dev/null ||\
		(git clone https://github.com/Ngoguey42/gnuplot-ocamlFORK gnuplot-ocaml &&\
		$(MAKE) -C gnuplot-ocaml\
		)

re: fclean all

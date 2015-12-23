# nodep.mli
# req1_b.mli   REQ->nodep.mli

# nodep.ml
# req1_a.ml   REQ->nodep.ml
# req1_b.ml   REQ->nodep.ml
# req3.ml   REQ->req1_a.ml & req1_b.ml
# main.ml   REQ->req3.ml $ Core

ocamlfind ocamlc *.mli nodep.ml req1_a.ml req1_b.ml req3.ml main.ml  -package yojson,core -thread -linkpkg

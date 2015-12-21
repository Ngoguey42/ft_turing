https://complexityzoo.uwaterloo.ca/Petting_Zoo
https://www.youtube.com/watch?v=7dpFeXV_hqs

ocamlopt.opt `ocamlfind query core`/core.cmxa -cclib "-L `ocamlfind query core`"  *.ml
```
oktf is an alias for
rr ;
ocamlfind ocamlcp *.ml -package yojson -package core -thread -linkpkg &&
printf "\033[33m" &&
ocamlfind ocamlc -i *.ml -package yojson -package core -thread -linkpkg &&
printf "\033[0m" &&
time ./a.out &&
rm a.out &&
ocl
```
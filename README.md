Small presentation:
- https://www.youtube.com/watch?v=7dpFeXV_hqs

18h of theory of computation (math oriented, accessible):
- https://www.youtube.com/user/hhp3/playlists

Compiler class:
- https://class.coursera.org/compilers/lecture

Misc:
- https://complexityzoo.uwaterloo.ca/Petting_Zoo
- http://www.wolframscience.com/nksonline/toc.html


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

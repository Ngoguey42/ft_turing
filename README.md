Small presentation:
- https://www.youtube.com/watch?v=7dpFeXV_hqs

18h of theory of computation (math oriented, accessible):
- https://www.youtube.com/user/hhp3/playlists

Compiler class:
- https://class.coursera.org/compilers/lecture

Misc:
- https://complexityzoo.uwaterloo.ca/Petting_Zoo
- http://www.wolframscience.com/nksonline/toc.html
- http://www.cba.mit.edu/events/03.11.ASE/docs/Minsky.pdf


```sh
#Compile machines/*.s files to machines/*.json:
python compiler/main.py machines/*.s
```

Turing Machines in ./machines
- TM0: machines/unary_sub.json #given in subject.pdf as an example
- TM1:
- TM2: machines/palindrome.json #version1
- TM2: machines/is_palindrome2.s #version2
- TM3:
- TM4: machines/zero_power_2n.json
- TM5: machines/utm.s #universal turing machine

More Turing Machines in ./machines
- machines/binary_divisable_by3.json
- machines/has_0011.json
- machines/minsky_utm.s #1967's Minsky universal turing machine
- machines/split_input.json #separate input with blank
- machines/zero_second_to_last.json

```sh
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

![encoding](./img/utm_encoding.png)<BR>

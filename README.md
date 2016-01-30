# FT_TURING, Jan 2016
>>>>> #####Deterministic Turing machine in Ocaml. (group project)

#####Grade ``(tbd/100)`` ``(tbd/125)*``
--------  -----------------------

Team: [fbuoro]() / [ngoguey](https://github.com/Ngoguey42).
<BR>

#####Goals:
- [ ] lol

#####Recommended bonuses:
- [ ] lol

#####Our work:
- [ ] lol

Turing Machines in ./machines
- TM0: machines/unary_sub.json	#given in subject.pdf as an example
- TM1: machines/unary_add.s
- TM2: machines/palindrome.json	#version1
- TM2: machines/is_palindrome2.s	#version2
- TM3: machines/0n1n.s
- TM4: machines/zero_power_2n.json
- TM5: machines/utm.s	#universal turing machine

More Turing Machines in ./machines
- machines/binary_divisable_by3.json
- machines/has_0011.json
- machines/minsky_utm.s	#1967 Minsky's universal turing machine
- machines/split_input.json	#separate input with blanks
- machines/zero_second_to_last.json

<BR>compile machines/*.s files to machines/*.json:<BR>
```sh
python compiler/main.py machines/*.s
```

<BR>Useful links:<BR>
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

```
*
- A grade of 85 was required to validate the project.
- A maximum grade of 125 was reachable.
- Second sessions are organised for failed projects.
```

<BR>
unary add:<BR>
![example_add](./img/example_add.png)<BR>
is input a palindrome:<BR>
![example_palindrome](./img/example_palindrome.png)<BR>
is input of form 0^2n:<BR>
![example_0p2n](./img/example_zeropower2n.png)<BR>
machines/utm.s encoding (universal turing machine):<BR>
![encoding](./img/utm_encoding.png)<BR>

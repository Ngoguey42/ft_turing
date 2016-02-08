# FT_TURING, Jan 2016
>>>>> #####Deterministic Turing machine in Ocaml. (group project)

#####Grade ``(tbd/100)`` ``(tbd/125)*``
--------  -----------------------

Team: [fbuoro]() / [ngoguey](https://github.com/Ngoguey42).
<BR>

#####Goals:
- [X] Create a deterministic, single headed and single tape Turing machine(TM).
- [X] Read a TM description from a json file.
- [X] Code in OCaml or Haskell, any version, library or tools authorized.
- [X] Write 5 turing machines in json form (see below)
- [X] Write an universal turing machine(TM5) able to run TM1

#####Recommended bonuses:
- [ ] Compute time complexity of a given TM

#####Our work:
- [X] Deep study of theory of computation (see **Useful links** below)
<BR><BR>
- [X] Study of core/batteries-included libraries (used core/list, core/dequeue)
- [X] [Small functional wrapper (YojsonTreeMatcher.ml)](srcs/YojsonTreeMatcher.ml?ts=4) for yojson, that unfolds two recursive variants side by side with callbacks.
- [X] [Loop detection (LoopGuard.ml)](srcs/LoopGuard.ml?ts=4) when TM act as a LBA.
- [X] ft_turing flag to convert json+input to TM5's input format
<BR><BR>
- [X] Conception of a pseudo-asm language to describe TMs, compilable to .json format ([compiler](./compiler/))
- [X] Advanced [TM5 (utm.s)](machines/utm.s?ts=4) able to run any other TM (including itself)
- [X] [TM3 (0n1n.s)](machines/0n1n.s?ts=4) running in O(Nlog(N)) and preserving input
- [X] more TM (see below)
<BR>
<BR>

> ####Mandatory Turing Machines in ./machines:
- TM0: machines/unary_sub.json  *given in subject.pdf as an example*
- TM1: machines/unary_add.s
- TM2: machines/palindrome.json	 *version1*
- TM2: machines/is_palindrome2.s  *version2*
- TM3: machines/0n1n.s
- TM4: machines/zero_power_2n.json
- TM5: machines/utm.s *universal turing machine*

> ####More Turing Machines in ./machines:
- machines/binary_divisable_by3.json
- machines/has_0011.json
- machines/minsky_utm.s	 *1967 Minsky's universal turing machine*
- machines/split_input.s  *separate input with blanks in O(3n^2)*
- machines/zero_second_to_last.json

<BR><BR>

####Compile machines/\*.s files to machines/\*.json:
```sh
python compiler/main.py machines/*.s
```

<BR><BR>

>###Useful links:
######Small presentation:
- https://www.youtube.com/watch?v=7dpFeXV_hqs

>######18h of theory of computation (math oriented, accessible):
- https://www.youtube.com/user/hhp3/playlists

>######Linear regression:
- http://www.dummies.com/how-to/content/how-to-calculate-a-regression-line.html
- https://www.youtube.com/watch?v=w2FKXOa0HGA

>######Misc:
- https://class.coursera.org/compilers/lecture
- https://class.coursera.org/algo-004/lecture
- https://complexityzoo.uwaterloo.ca/Petting_Zoo
- http://www.wolframscience.com/nksonline/toc.html
- http://www.cba.mit.edu/events/03.11.ASE/docs/Minsky.pdf

<BR><BR>

---

```
*
- A grade of 85 was required to validate the project.
- A maximum grade of 125 was reachable.
- Second sessions are organised for failed projects.
```

---

> unary add:<BR>
![example_add](./img/example_add.png)

<BR>
> is input a palindrome:<BR>
![example_palindrome](./img/example_palindrome.png)

<BR>
> is input of form 0^2n:<BR>
![example_0p2n](./img/example_zeropower2n.png)

<BR>
> machines/utm.s encoding (universal turing machine):<BR>
![encoding](./img/utm_encoding.png)


---

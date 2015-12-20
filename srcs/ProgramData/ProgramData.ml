(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ProgramData.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 14:07:39 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/20 15:35:12 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Final representation of the program
 * fastest form possible
 * no init error here
 * no runtime error either *)
(* transition array :
 * int_of_char indexed
 * must be of size 256 *)
(*
 * 		Outside sets self state to state
 *		Outside reads char from Tape
 *		Get transition from state / char
 *		| Final	-> state was final, exit
 *		| Normal -> char / action / state
 *		Outside write Tape
 *		Outside moves Head
 *)

type state_index = int
type action = Left | Right

type transition = Normal of char * action * state_index
				| Final
				| Undefined

type t = {
	name		: string;
	alphabet	: char array;
	blank		: char;
	states		: (string * transition array) array;
	initial		: state_index;
  }

let create _ =
  {
	name = "todo";
	alphabet = [|'a'; 'b'|];
	blank = 'c';
	states = [|
			 (*   ("todo", [|Final|]) *)
			 (* ; ("todo", [|Final|]) *)
			 (* ; ("todo", [| *)
			 (* 	  Normal ('c', Left, 42) *)
			 (* 	; Normal ('c', Left, 42) *)
			 (* 	; Final *)
			 (* 	|]) *)
			 |];
	initial = 42;
  }

let transition : t -> int -> char ->
				 transition = fun {states} state_index char ->
  let _, transitions = states.(state_index) in
  transitions.(int_of_char char)

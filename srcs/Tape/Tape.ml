(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Tape.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/15 14:00:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/15 17:49:37 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Representation of Turing's tape.
 * 1 head char.
 * 2 stacks for left/right sides, behaving as a kind of deque.
 * 1 blank char for stack padding
 * 1 index relative to the initial position of the head.
 *)

type t = {
	left	: char Stack.t;
	head	: char;
	right	: char Stack.t;
	blank	: char;
	i		: int;
  }

type move = Left | Right


(* of_string ************************ *)

let rec _string_to_stack stack str i =
  if i > 1 then (
	Stack.push (String.get str i) stack;
	_string_to_stack stack str (i - 1)
  )

let of_string str blank =
  let right = Stack.create () in
  let head = match String.length str with
	| 0 -> blank
	| _ -> String.get str 0
  in
  _string_to_stack right str (String.length str - 1);
  { left = Stack.create ()
  ; head = head
  ; right = right
  ; blank = blank
  ; i = 0 }


(* action *************************** *)

let action ({left = l; right = r; blank = blank; i = i} as tape) input move =
  let dst, src, di = match move with
	| Left	-> r, l, -1
	| Right	-> l, r, 1
  in
  let head = match Stack.length src with
	| 0		-> blank
	| _		-> Stack.pop src
  in
  Stack.push input dst;
  {tape with i = i + di
		   ; head = head}


(* index **************************** *)

let index {i = i} =
  i


(* head ***************************** *)

let head {head = h} =
  h

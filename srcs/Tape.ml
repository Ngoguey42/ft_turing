(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Tape.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/15 14:00:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/19 12:17:23 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Representation of Turing's tape.
 * 1 head char.
 * 2 stacks for left/right sides, behaving as a kind of deque.
 * 1 blank char for stack padding
 * 1 index relative to the initial position of the head.
 *)

include Action

type t = {
	left	: char Stack.t;
	head	: char;
	right	: char Stack.t;
	blank	: char;
	i		: int;
  }

(* of_string ************************ *)

let rec _string_to_stack stack str i =
  if i > 0 then (
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

let action ({left = l; right = r; blank = blank; i = i} as tape) input action =
  let dst, src, di = match action with
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

(* print **************************** *)

let print {left; head; right; i} =
  let left_stacklen = Stack.length left in
  let len = left_stacklen + 5 + 1 + 4 + Stack.length right in
  let str = Bytes.create len in
  let i = ref 0 in

  Stack.iter (fun c ->
  	  Bytes.set str (left_stacklen - !i - 1) c;
	  incr i
  	) left;
  Bytes.blit_string "\027[31m" 0 str !i 5;
  i := !i + 5;
  Bytes.set str !i head;
  i := !i + 1;
  Bytes.blit_string "\027[0m" 0 str !i 4;
  i := !i + 4;
  Stack.iter (fun c ->
  	  Bytes.set str !i c;
	  incr i
  	) right;
  print_bytes str;
  ()

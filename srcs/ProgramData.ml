(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ProgramData.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 14:07:39 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/09 15:48:49 by ngoguey          ###   ########.fr       *)
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

include Action

type state_index = int

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

let (++) = (@@)
let _alphabet_to_string al =
  let _, str = Array.fold_left (fun (i, str) c ->
				   let str = Printf.sprintf "%s[%d]='%c'; " str i c in
				   (i + 1, str)
				 ) (0, "") al in
  str

let _transitions_to_string transarr states =
  let _, str = Array.fold_left (fun (i, str) trans ->
				   match trans with
				   | Normal (wr, act, nexti) ->
					  let next, _ = states.(nexti) in
					  let actstr = match act with
						| Left -> "Left "
						| Right -> "Right"
					  in
					  (i + 1,
					   Printf.sprintf "%s\t\t[%c]=(wr:'%c', act:%s, to:%d(%s))\n"
									  str (char_of_int i) wr actstr nexti next
					  )
				   | _ -> (i + 1, str)
				 ) (0, "") transarr
  in
  match str, transarr.(0) with
  | "", Final -> "\t\tFinal\n"
  | "", _ -> "\t\tNo Transitions\n"
  | _, _ -> str

let _states_to_string states =
  let _, str = Array.fold_left (fun (i, str) (state, transarr) ->
				   let str = Printf.sprintf "%s\t[%d]=%s\n%s"
											str i state
							 ++ _transitions_to_string transarr states
				   in
				   (i + 1, str)
				 ) (0, "") states
  in
  str


let print db =
  Printf.printf "Program \"%s\" Blank is '%c' Initial is (%d)\n\
				 Alphabet [%s] \nStates:%s\n%!"
				db.name db.blank db.initial
				(_alphabet_to_string db.alphabet)
				(_states_to_string db.states)

(* ++ _alphabet_to_string db.alphabet *)
(* ++ _states_to_string db.states *)
(* ++ _transitions_to_string db.transitions *)

let _make_alphabet {ProgramDataTmp.alphabet} =
  let alphabet = match alphabet with None -> assert false | Some a -> a in
  let _, alpha =
	ProgramDataTmp.CharSet.fold
	  (fun elt (i, a) -> a.(i) <- elt; (i + 1, a))
	  alphabet (0, Array.make (ProgramDataTmp.CharSet.cardinal alphabet) 'c')
  in
  alpha

let _array_index pred a =
  let rec aux i =
	if pred a.(i)
	then i
	else if i >= Array.length a
	then assert false
	else aux (i + 1)
  in
  aux 0

let _make_states {ProgramDataTmp.finals
				 ; ProgramDataTmp.transitions
				 ; ProgramDataTmp.states} =
  let states = match states with None -> assert false | Some s -> s in
  let st = Array.make (ProgramDataTmp.StringSet.cardinal states) ("", [||]) in
  let _, st =
	ProgramDataTmp.StringSet.fold
	  (fun elt (i, a) ->
		let transarr = match ProgramDataTmp.StringSet.mem elt finals with
		  | true -> Array.make 256 Final
		  | false -> Array.make 256 Undefined
		in
		a.(i) <- (elt, transarr);
		(i + 1, a)
	  )
	  states (0, st)
  in
  Array.iteri (fun i (elt, transarr) ->
	  let trans_map = ProgramDataTmp.TransitionMap.filter
						(fun (elt', _) _ -> elt = elt') transitions
	  in
	  ProgramDataTmp.TransitionMap.iter
		(fun _ {ProgramDataTmp.read; ProgramDataTmp.to_state
				; ProgramDataTmp.write; ProgramDataTmp.action} ->
		  transarr.(int_of_char read) <-
			Normal (write, action, _array_index
									 (fun (st, _) -> st = to_state) st)
		 ;
		   ()
		) trans_map;
	  st.(i) <- (elt, transarr);
	) st;

  st


let _create : ProgramDataTmp.parsing_data -> t =
  fun ({ProgramDataTmp.name; ProgramDataTmp.blank; ProgramDataTmp.initial
	   } as tmp) ->
  let states = _make_states tmp in
  {
	name;
	alphabet = _make_alphabet tmp;
	blank;
	states;
	initial = _array_index (fun (st, _) -> st = initial) states;
  }

let of_jsonfile jsonfile =
  let j = try Yojson.Basic.from_file jsonfile with
		  | Yojson.Json_error msg -> failwith @@ jsonfile ^ ":\n" ^ msg
  in
  let data = match YojsonTreeMatcher.unfold
					 ProgramDataTmp.default YojsonTree.file_semantic j with
	| MonadicTry.Fail why -> failwith @@ "Json unfold failed :\n" ^ why
	| MonadicTry.Success data' -> data' in

  _create data

let transition : t -> int -> char ->
				 transition = fun {states} state_index char ->
  let _, transitions = states.(state_index) in
  transitions.(int_of_char char)

let state_name : t -> int -> string = fun {states} state_index ->
  let state, _  = states.(state_index) in
  state

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ProgramDataTmp.ml                                  :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 14:03:44 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/25 18:30:45 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

include Action

module CharSet = Set.Make(struct
						   type t = char
						   let compare = Pervasives.compare
						 end)
module StringSet = Set.Make(struct
							 type t = string
							 let compare = Pervasives.compare
						   end)
module TransitionMap = Map.Make(struct
								 type t = string * char
								 let compare = Pervasives.compare
							   end)

type transition_data = {
	read		: char;
	to_state	: string;
	write		: char;
	action		: action;
  }

(* Presence of all field guaranteed by semantic *)
type parsing_data = {
	name		: string;
	blank		: char;
	initial		: string;
	finals		: StringSet.t;

	(* alphabet is an option for a better error handling later *)
	alphabet	: CharSet.t option;
	(* states is an option for a better error handling later *)
	states		: StringSet.t option;

	trans_state	: string;
	trans_tmp	: int * transition_data;
	transitions	: transition_data TransitionMap.t;
  }


let _finals_to_string finals =
  StringSet.fold (fun elt str -> str ^ elt ^ "; ") finals ""

let _alphabet_to_string alphabet =
  match alphabet with
  | None -> "None"
  | Some al -> CharSet.fold (fun elt str -> Printf.sprintf "%s%c; " str elt)
							al "[" ^ "]"

let _states_to_string states =
  match states with
  | None -> "None"
  | Some st -> StringSet.fold (fun elt str -> Printf.sprintf "%s%s; " str elt)
							  st "[" ^ "]"

let _transitions_to_string transitions =
  TransitionMap.fold
	(fun (st, read) v str ->
	  (match v.action with
	   | Left -> "Left"
	   | Right -> "Right")
	  |> Printf.sprintf "%s(%s, %c):{%s; %c; %s}\n"
						str st read v.to_state v.write
	) transitions ""


let (++) = (@@)

let print : parsing_data -> unit = fun db ->
  Printf.printf "n:'%s' c:'%c' i:'%s' f:[%s] \nalpha:%s \nstates:%s\n%s\n%!"
				db.name db.blank db.initial
  ++ _finals_to_string db.finals
  ++ _alphabet_to_string db.alphabet
  ++ _states_to_string db.states
  ++ _transitions_to_string db.transitions

let default =
  {name = ""; blank = '0'; initial = ""; finals = StringSet.empty
   ; alphabet = None; states = None
   ; trans_state = ""
   ; trans_tmp = (0, {read = '0'; to_state = ""; write = '0'; action = Left})
   ; transitions = TransitionMap.empty
  }

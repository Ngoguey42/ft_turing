(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/20 18:41:58 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let f = Yojson.Basic.from_file

type json = [ `Assoc
			| `List
			| `String ]

(* type json = [ `Assoc of (string * json) list *)
(* 			| `String of string ] *)
(* 			| `List of json list *)

(* 			| `Bool of bool *)
(* 			| `Float of float *)
(* 			| `Int of int *)
(* 			| `Null *)

type funtype = Fun of string | NoFun

type handler =
  | StaticAssoc of (string, (funtype * handler)) Hashtbl.t
  (* htable[string].funtype takes a (string * json) *)
  (* htable[string].handler applied on each assoc's rhs *)

  | DynamicAssoc of funtype * funtype * handler
  (* funtype#1 takes a (string * json) list *)
  (* funtype#2 takes repeated (string * json) *)
  (* handler applied on each assoc's elements *)

  | List of funtype * funtype * handler
  (* funtype#1 takes a json list *)
  (* funtype#2 takes repeated json *)
  (* handler applied on each list's elements *)

  | String of funtype
  (* funtype takes a string *)

  | NoHandle


(* ~| Hashtbl constructor *)
let (~|) : ('a * 'b) array -> ('a, 'b) Hashtbl.t = fun a ->
  let ht = Hashtbl.create (Array.length a) in
  Array.iter (fun (k, v) -> Hashtbl.add ht k v) a;
  ht

(* ~~ Hashtbl entry constructor *)
let (~~) : 'a -> 'b -> 'c -> 'a * ('b * 'c) = fun n f c ->
  n, (f, c)

(* ~> Fun constructor *)
let (~>) : string -> funtype = fun fname ->
  Fun fname

let transition_handler =
  StaticAssoc
	~| [|
	  ~~ "read" NoFun @@ String ~>"sv_trans_read"
	; ~~ "to_state" NoFun @@ String ~>"sv_trans_tostate"
	; ~~ "write" NoFun @@ String ~>"sv_trans_write"
	; ~~ "action" NoFun @@ String ~>"sv_trans_action"
	|]

let transitions_handler =
  DynamicAssoc (~>"ck_trans_count", ~>"sv_trans_name",
				List (~>"ck_substransitions_count", NoFun, transition_handler))

let file_handler =
  StaticAssoc
	~| [|
	  ~~ "name" NoFun @@ String ~>"sv_name"
	; ~~ "blank" NoFun @@ String ~>"sv_blank"
	; ~~ "initial" NoFun @@ String ~>"sv_initial"
	; ~~ "alphabet" NoFun
	  @@ List (~>"ck_letters_count", NoFun, String ~>"sv_letter")
	; ~~ "states" NoFun
	  @@ List (~>"ck_states_count", NoFun, String ~>"sv_state")
	; ~~ "finals" NoFun
	  @@ List (~>"ck_finals_count", NoFun, String ~>"sv_final")
	; ~~ "transitions" NoFun @@ transitions_handler
	|]

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/21 12:26:30 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let f = Yojson.Basic.from_file


(* type jsonlololol = [ `Assoc *)
(* 				   | `List *)
(* 				   | `String ] *)
let f : Yojson.Basic.json -> unit = fun a ->
  match a with
  | `Bool b ->
	 Printf.eprintf "bool %b\n%!" b
  | _ -> ()

let v = f (`Null)
(* let v = f (`Bool true) *)




(* type json = [ `Assoc of (string * json) list *)
(* 			| `String of string ] *)
(* 			| `List of json list *)
(* 			| `Bool of bool *)
(* 			| `Float of float *)
(* 			| `Int of int *)
(* 			| `Null *)

type funtype = Fun of string | NoFun

type handler =
  | StaticAssoc of (string, (funtype * handler)) Hashtbl.t * bool
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





(* ~| StaticAssoc constructor *)
let (~|) : ('a * 'b) array -> bool -> handler = fun a b ->
  let ht = Hashtbl.create @@ Array.length a in
  Array.iter (fun (k, v) -> Hashtbl.add ht k v) a;
  StaticAssoc (ht, b)

(* ~~ Hashtbl entry constructor *)
let (~~) : 'a -> 'b -> 'c -> 'a * ('b * 'c) = fun n f c ->
  n, (f, c)


type parsing_data = {
	name		: string option;
	blank		: string option;
	initial		: string option;

	alphabet	: string list option;
	states		: string list option;
	finals		: string list option;

	(* transitions	: *)
  }


let transition_handler =
  ~| [|
	  ~~ "read" NoFun @@ String (Fun "sv_trans_read")
	; ~~ "to_state" NoFun @@ String (Fun "sv_trans_tostate")
	; ~~ "write" NoFun @@ String (Fun "sv_trans_write")
	; ~~ "action" NoFun @@ String (Fun "sv_trans_action")
	|] true

let transitions_handler =
  DynamicAssoc ((Fun "ck_trans_count"), (Fun "sv_trans_name"),
				List (NoFun, NoFun, transition_handler))

let file_handler =
  ~| [|
	  ~~ "name" NoFun @@ String (Fun "sv_name")
	; ~~ "blank" NoFun @@ String (Fun "sv_blank")
	; ~~ "initial" NoFun @@ String (Fun "sv_initial")

	; ~~ "transitions" NoFun @@ transitions_handler

	; ~~ "alphabet" NoFun
	  @@ List ((Fun "ck_letters_count"), NoFun, String (Fun "sv_letter"))
	; ~~ "states" NoFun
	  @@ List ((Fun "ck_states_count"), NoFun, String (Fun "sv_state"))
	; ~~ "finals" NoFun
	  @@ List ((Fun "ck_finals_count"), NoFun, String (Fun "sv_final"))
	|] true

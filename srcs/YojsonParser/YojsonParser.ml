(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/20 17:46:03 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let f = Yojson.Basic.from_file

type json = [ `Assoc
			| `List
			| `String ]
(* type json = [ `Assoc of (string * json) list *)
(* 			(\* | `Bool of bool *\) *)
(* 			(\* | `Float of float *\) *)
(* 			(\* | `Int of int *\) *)
(* 			| `List of json list *)
(* 			(\* | `Null *\) *)
(* 			| `String of string ] *)

type funtype = Fun of string | NoFun

type handler =
  | StaticAssoc of (string, (funtype * handler)) Hashtbl.t
  (* htable[string].funtype takes a (string * json) *)
  (* htable[string].handler applied on each assoc's rhs *)

  | DynamicAssoc of funtype * handler
  (* funtype takes a (string * json) list *)
  (* handler applied on each assoc's elements *)

  | List of funtype * handler
  (* funtype takes a json list *)
  (* handler applied on each list's elements *)

  | String of funtype
  (* funtype takes a string *)

  | NoHandle


let _hashtbl_of_array a =
  let ht = Hashtbl.create (Array.length a) in
  Array.iter (fun (k, v) -> Hashtbl.add ht k v) a;
  ht

let (~|) a = _hashtbl_of_array a
let (~~) n f c = n, (f, c)

let t =
  StaticAssoc
	~| [|
	  ~~ "name" NoFun @@ String (Fun "save_name")
	; ~~ "alphabet" NoFun @@ List (NoFun, String (Fun "save_letter"))
	; ~~ "blank" NoFun @@ String (Fun "save_blank")
	; ~~ "states" NoFun @@ List (NoFun, String (Fun "save_state"))
	; ~~ "initial" NoFun @@ String (Fun "save_initial")
	; ~~ "finals" NoFun @@ List (NoFun, String (Fun "save_final"))
	; ~~ "transitions" NoFun @@ DynamicAssoc ((Fun "save_transitions"), NoHandle)
	|]

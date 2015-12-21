(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/21 17:38:20 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)



(* (\* type jsonlololol = [ `Assoc *\) *)
(* (\* 				   | `List *\) *)
(* (\* 				   | `String ] *\) *)
(* let f : Yojson.Basic.json -> unit = fun a -> *)
(*   match a with *)
(*   | `Bool b -> *)
(* 	 Printf.eprintf "bool %b\n%!" b *)
(*   | _ -> () *)

(* let v = f (`Null) *)
(* (\* let v = f (`Bool true) *\) *)




(* type json = [ `Assoc of (string * json) list *)
(* 			| `String of string ] *)
(* 			| `List of json list *)

(* 			| `Bool of bool *)
(* 			| `Float of float *)
(* 			| `Int of int *)
(* 			| `Null *)

(* ************************************************************************** *)
(* Yojson Semantic Matcher *)

type 'a status = Fail of string | Success of 'a

type 'a func = 'a -> string -> 'a status


(* AssocDeclared; *)
(* AssocDefined *)
type 'a handler = AssocStatic of bool * bool * (string, 'a handler) Hashtbl.t
				| AssocDynamic of bool * int * 'a func * 'a handler
				| List of int * 'a handler
				| String of 'a func

let assoc_static ~uniq ~compl fields =
  AssocStatic (uniq, compl, fields)

let assoc_dynamic ~uniq ~min ~f entries =
  AssocDynamic (uniq, min, f, entries)

let list ~min entries =
  List (min, entries)


let rec handle_assoc_static data l (_, _, fields) =
  Printf.eprintf "handle_assoc_static\n%!";
  List.iter (fun (str, json') ->
	  let sem' = Hashtbl.find fields str in
	  Printf.eprintf "handle_assoc_static loop with %s\n%!" str;
	  aux data sem' json'
	) l;
  ()

and handle_assoc_dynamic data l (_, _, _, entries) =
  Printf.eprintf "handle_assoc_dynamic\n%!";
  List.iter (fun (str, json') ->
	  Printf.eprintf "handle_assoc_dynamic loop with %s\n%!" str;
	  aux data entries json'
	) l;
  ()

and handle_list data l (_, entries) =
  Printf.eprintf "handle_list\n%!";
  List.iter (fun (json') ->
	  Printf.eprintf "handle_list loop\n%!";
	  aux data entries json'
	) l;
	()

and handle_string data str fn =
  Printf.eprintf "handle_string with %s \n%!" str;
  ()

and aux data sem json =
  match sem, json with
  | AssocStatic (b, b', ht),	`Assoc l -> handle_assoc_static data l (b, b', ht)
  | AssocDynamic (b,i,f,h),		`Assoc l -> handle_assoc_dynamic data l (b,i,f,h)
  | List (i,a),					`List l -> handle_list data l (i,a)
  | String fn, 					`String s -> handle_string data s fn

  | AssocStatic _, _ | AssocDynamic _, _ -> failwith "Unmatching assoc"
  | List _, _ -> failwith "Unmatching list"
  | String _, _ -> failwith "Unmatching string"


let unfold data semantic json =
  aux data semantic json;
  data


(* ************************************************************************** *)
(* TmpProgramData *)

(* type transition_data = { *)
(* 	read		: string option; *)
(* 	to_state	: string option; *)
(* 	write		: string option; *)
(* 	action		: string option; *)
(*   } *)

type parsing_data = {
	name		: string option;
	(* blank		: string option; *)
	(* initial		: string option; *)

	(* alphabet	: string list option; *)
	(* states		: string list option; *)
	(* finals		: string list option; *)

	(* transitions	: transition_data; *)
  }

(* ************************************************************************** *)
(* Program Creator *)

let placeholder (db: int) str =
  Fail "lol"

(* ~| Hashtbl constructor from array *)
let (~|) : ('a * 'b) array -> ('a, 'b) Hashtbl.t = fun a ->
  let ht = Hashtbl.create @@ Array.length a in
  Array.iter (fun (k, v) -> Hashtbl.add ht k v) a;
  ht

(* let save_blank_char database string = *)
(*   if String.length string <> 1 then *)
(* 	Fail "fail lol" *)
(*   else ( *)
(* 	let blank = string.(0) in *)
(* 	if not (Hashtbl.mem database.alphabetHmap blank) then *)
(* 	  Fail "invaild char" *)
(* 	else *)
(* 	  Success {database with blank} *)
(*   ) *)

let transition_semantic =
  list ~min:0
  @@ assoc_static ~uniq:true ~compl:true
  @@ ~| [|
		 "read", String placeholder
	   ; "to_state", String placeholder
	   ; "write", String placeholder
	   ; "action", String placeholder
	   |]

let file_semantic =
  assoc_static ~uniq:true ~compl:true
  @@ ~| [|
		 "name", String placeholder
	   ; "alphabet" , list ~min:1 (String placeholder)
	   ; "blank", String placeholder

	   ; "initial", String placeholder
	   ; "states" , list ~min:1 (String placeholder)
	   ; "finals", list ~min:1 (String placeholder)
	   ; "transitions", assoc_dynamic ~uniq:true ~min:0 ~f:placeholder
									  transition_semantic
	   |]


(* ************************************************************************** *)
(* Main *)

let () =
  let j = Yojson.Basic.from_file "unary_sub.json" in
  let data = {name = None} in
  let data = unfold data file_semantic j in
  (* Yojson.Basic.pretty_to_channel ~std:false stdout j; *)
  ()

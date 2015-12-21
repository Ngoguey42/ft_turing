(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/21 18:45:44 by ngoguey          ###   ########.fr       *)
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


let (++) = (@@)
let (/>) = (|>)

let errormsg fname why json =
  Yojson.Basic.pretty_to_string json
  |> Printf.sprintf "%s failed because \"%s\" at \"%s\"" fname why


let errormsg2 fname why json json' =
  Printf.sprintf "%s failed because \"%s\" at \"%s\" in \"%s\"" fname why
  ++ Yojson.Basic.pretty_to_string json
  ++ Yojson.Basic.pretty_to_string json'


let rec handle_assoc_static data l (uniq, compl, fields) =
  (* Printf.eprintf "handle_assoc_static\n%!"; *)
  let llen =  List.length l in
  let uniqlen = List.length @@ List.sort_uniq Pervasives.compare l in

  if uniq && uniqlen <> llen then
	failwith
	@@ errormsg "handle_assoc_static"
	   ++ Printf.sprintf "duplicates not allowed by parameter"
	   ++ `Assoc l;

  if compl && Hashtbl.length fields <> uniqlen then
	failwith
	@@ errormsg "handle_assoc_static"
	   ++ Printf.sprintf "missing field not allowed by parameter"
	   ++ `Assoc l;

  List.fold_left (fun data' (str, json') ->
	  let sem' = Hashtbl.find fields str in
	  (* Printf.eprintf "handle_assoc_static loop with %s\n%!" str; *)
	  aux data' sem' json'
	) data l


and handle_assoc_dynamic data l (uniq, min, fn, entries) =
  (* Printf.eprintf "handle_assoc_dynamic\n%!"; *)
  let llen =  List.length l in

  if uniq && List.length @@ List.sort_uniq Pervasives.compare l <> llen then
	failwith
	@@ errormsg "handle_assoc_dynamic"
	   ++ Printf.sprintf "duplicates not allowed by parameter"
	   ++ `Assoc l;

  if llen < min then
	failwith
	@@ errormsg "handle_assoc_dynamic"
	   ++ Printf.sprintf "list length to low (%d < %d)" llen min
	   ++ `Assoc l;

  List.fold_left (fun data' (str, json') ->
	  (* Printf.eprintf "handle_assoc_dynamic loop with %s\n%!" str; *)
	  match fn data' str with
	  | Fail why -> failwith
					@@ errormsg2 "handle_assoc_dynamic" why
					   ++ `String str
					   ++ `Assoc l
	  | Success data'' -> aux data'' entries json'
	) data l


and handle_list data l (min, entries) =
  (* Printf.eprintf "handle_list\n%!"; *)
  if List.length l < min then
	failwith
	@@ errormsg "handle_string"
	   ++ Printf.sprintf "list length to low (%d < %d)" (List.length l) min
	   ++ `List l;

  List.fold_left (fun data' (json') ->
	  (* Printf.eprintf "handle_list loop\n%!"; *)
	  aux data' entries json'
	) data l


and handle_string data str fn =
  (* Printf.eprintf "handle_string with %s \n%!" str; *)
  match fn data str with
  | Fail why -> errormsg "handle_string" why @@ `String str |> failwith
  | Success data' -> data'


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
  aux data semantic json


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

let placeholder (db: parsing_data) str =
  (* Fail "lol" *)
  Success db

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

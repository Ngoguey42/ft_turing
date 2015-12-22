(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/22 16:47:53 by ngoguey          ###   ########.fr       *)
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
(* YojsonTreeMatcher *)
(* Unfolds side by side an ('a node) and a (Yojson.Basic.json)
 *)

type 'a status = Fail of string | Success of 'a

type 'a func = 'a -> string -> 'a status

type 'a node = AssocKnown of bool * bool * (string, 'a node) Hashtbl.t
			 | AssocUnknown of bool * int * 'a func * 'a node
			 | List of int * 'a node
			 | String of 'a func

let assoc_known ~uniq ~compl fields =
  AssocKnown (uniq, compl, fields)

let assoc_unknown ~uniq ~min ~f entries =
  AssocUnknown (uniq, min, f, entries)

let list ~min entries =
  List (min, entries)


let rec monoid_fold_left f data l =
  match l with
  | hd::tl -> (match f data hd with
			   | Fail why -> Fail why
			   | Success data' -> monoid_fold_left f data' tl)
  | _ -> Success data


let (++) = (@@)

let error fname why json =
  Fail (
	  Printf.sprintf "%s failed because \"%s\" at \"%s\"" fname why
	  @@ Yojson.Basic.pretty_to_string json)

let error2 fname why json json' =
  Fail (
	  Printf.sprintf "%s failed because \"%s\" at \"%s\" in \"%s\"" fname why
	  ++ Yojson.Basic.pretty_to_string json
	  ++ Yojson.Basic.pretty_to_string json')


let rec handle_assoc_known data l (uniq, compl, fields) =
  (* Printf.eprintf "handle_assoc_known\n%!"; *)
  let llen =  List.length l in
  let uniqlen = List.length @@ List.sort_uniq Pervasives.compare l in (* TODO: Check exactitude lol *)

  if uniq && uniqlen <> llen then
	error "handle_assoc_known"
	++ Printf.sprintf "duplicates not allowed by parameter"
	++ `Assoc l

  else if compl && Hashtbl.length fields <> uniqlen then
	error "handle_assoc_known"
	++ Printf.sprintf "missing field not allowed by parameter"
	++ `Assoc l

  else monoid_fold_left (fun data' (str, json') ->
		   let sem' = Hashtbl.find fields str in
		   (* Printf.eprintf "handle_assoc_known loop with %s\n%!" str; *)
		   aux data' sem' json'
		 ) data l


and handle_assoc_unknown data l (uniq, min, fn, entries) =
  (* Printf.eprintf "handle_assoc_unknown\n%!"; *)
  let llen =  List.length l in

  if uniq && List.length @@ List.sort_uniq Pervasives.compare l <> llen then
	error "handle_assoc_unknown"
	++ Printf.sprintf "duplicates not allowed by parameter"
	++ `Assoc l

  else if llen < min then
	error "handle_assoc_unknown"
	++ Printf.sprintf "list length to low (%d < %d)" llen min
	++ `Assoc l

  else monoid_fold_left (fun data' (str, json') ->
		   (* Printf.eprintf "handle_assoc_unknown loop with %s\n%!" str; *)
		   match fn data' str with
		   | Fail why -> error2 "handle_assoc_unknown" why
						 ++ `String str
						 ++ `Assoc l
		   | Success data'' -> aux data'' entries json'
		 ) data l


and handle_list data l (min, entries) =
  (* Printf.eprintf "handle_list\n%!"; *)
  if List.length l < min then
	error "handle_string"
	++ Printf.sprintf "list length to low (%d < %d)" (List.length l) min
	++ `List l

  else monoid_fold_left (fun data' (json') ->
		   (* Printf.eprintf "handle_list loop\n%!"; *)
		   aux data' entries json'
		 ) data l


and handle_string data str fn =
  (* Printf.eprintf "handle_string with %s \n%!" str; *)
  match fn data str with
  | Fail why -> error "handle_string" why ++ `String str
  | Success data' -> Success data'


and aux data sem json =
  match sem, json with
  | AssocKnown (b, b', ht),	`Assoc l -> handle_assoc_known data l (b, b', ht)
  | AssocUnknown (b,i,f,h),		`Assoc l -> handle_assoc_unknown data l (b,i,f,h)
  | List (i,a),					`List l -> handle_list data l (i,a)
  | String fn, 					`String s -> handle_string data s fn

  | AssocKnown _, _ | AssocUnknown _, _ -> Fail "Unmatching assoc"
  | List _, _ -> Fail "Unmatching list"
  | String _, _ -> Fail "Unmatching string"


let unfold data semantic json =
  aux data semantic json


(* ************************************************************************** *)
(* ProgramDataTmp *)

type action = Left | Right

type transition_data = {
	read		: char;
	to_state	: string;
	write		: char;
	action		: action;
  }

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

let print : parsing_data -> unit = fun db ->
  let f = StringSet.fold (fun elt str -> str ^ elt ^ "; ") db.finals "" in
  let al = match db.alphabet with
	| None -> "None"
	| Some al -> CharSet.fold (fun elt str -> Printf.sprintf "%s%c; " str elt)
							  al "[" ^ "]"
  in
  let st = match db.states with
	| None -> "None"
	| Some st -> StringSet.fold (fun elt str -> Printf.sprintf "%s%s; " str elt)
								st "[" ^ "]"
  in
  let tr = TransitionMap.fold
			 (fun (st, read) v str ->
			   (match v.action with
				| Left -> "Left"
				| Right -> "Right")
			   |> Printf.sprintf "%s(%s, %c):{%s; %c; %s}\n"
								 str st read v.to_state v.write
			 ) db.transitions ""
  in
  Printf.eprintf "n:'%s' c:'%c' i:'%s' f:[%s] \nalpha:%s \nstates:%s\n%s\n%!"
				 db.name db.blank db.initial f al st tr


(* ************************************************************************** *)
(* ProgramCreator *)

let placeholder (db: parsing_data) str =
  (* Fail "lol" *)
  Success db

let save_name db name =
  Success {db with name}

let save_letter ({alphabet} as db) str =
  if String.length str <> 1 then
	Fail "String.length str <> 1"
  else (
	let c = String.get str 0 in
	match alphabet with
	| None -> Success {db with alphabet = Some (CharSet.add c @@ CharSet.empty)}
	| Some set when CharSet.mem c set -> Fail "Duplicate in alphabet"


	(* | Some set -> Hashtbl.add db.alphabet c; *)
	(* 			  Success db *)
	| Some set -> Success {db with alphabet = Some (CharSet.add c set)}
  )

let save_blank ({alphabet} as db) str =
  if String.length str <> 1 then
	Fail "String.length str <> 1"
  else (
	let c = String.get str 0 in
	match alphabet with
	| None -> Fail "alphabet not defined"
	| Some set when not (CharSet.mem c set) -> Fail "Not present in alphabet"
	| _ -> Success {db with blank = c}
  )

let save_state ({states} as db) str =
  match states with
  | None -> Success {db with states = Some (StringSet.add str @@ StringSet.empty)}
  | Some set when StringSet.mem str set -> Fail "Duplicate in states"
  | Some set -> Success {db with states = Some (StringSet.add str set)}

let save_initial ({states} as db) str =
  match states with
  | None -> Fail "states not defined"
  | Some set when not (StringSet.mem str set) -> Fail "Not present in states"
  | _ -> Success {db with initial = str}

let save_finals ({states; finals} as db) str =
  match states with
  | None -> Fail "states not defined"
  | Some set when not (StringSet.mem str set) -> Fail "Not present in states"
  | Some set when StringSet.mem str finals -> Fail "Duplicate in finals"
  | _ -> Success {db with finals = StringSet.add str finals}


let save_trans_state ({states} as db) str =
  match states with
  | None -> Fail "states not defined"
  | Some set when not (StringSet.mem str set) -> Fail "Not present in states"
  | _ -> Success {db with trans_state = str}

let save_transition ({trans_tmp = (_, record)
					 ; transitions; trans_state} as db) trans =
  Success {db with trans_tmp = (0, record)
				 ; transitions = TransitionMap.add
								   (trans_state, trans.read) trans transitions}

let save_trans_read ({trans_tmp; alphabet} as db) str =
  if String.length str <> 1 then
	Fail "String.length str <> 1"
  else (
	let c = String.get str 0 in
	match alphabet with
	| None -> Fail "alphabet not defined"
	| Some set when not (CharSet.mem c set) -> Fail "Not present in alphabet"
	| _ -> let count, dat = trans_tmp in
		   let dat = {dat with read = c} in
		   Printf.eprintf "bordel count %d\n%!" count;
		   if count = 3 then
			 save_transition db dat
		   else
			 Success {db with trans_tmp = (count + 1, dat)}
  )


(* ~| Hashtbl constructor from array *)
let (~|) : ('a * 'b) array -> ('a, 'b) Hashtbl.t = fun a ->
  let ht = Hashtbl.create @@ Array.length a in
  Array.iter (fun (k, v) -> Hashtbl.add ht k v) a;
  ht

let transition_semantic =
  list ~min:0
  @@ assoc_known ~uniq:true ~compl:true
  @@ ~| [|
		 "read", String save_trans_read
	   ; "to_state", String placeholder
	   ; "write", String placeholder
	   ; "action", String placeholder
	   |]

let file_semantic =
  assoc_known ~uniq:true ~compl:true
  @@ ~| [|
		 "name", String save_name
	   ; "alphabet" , list ~min:1 (String save_letter)
	   ; "blank", String save_blank

	   ; "initial", String save_initial
	   ; "states" , list ~min:1 (String save_state)
	   ; "finals", list ~min:1 (String save_finals)
	   ; "transitions", assoc_unknown ~uniq:true ~min:0 ~f:save_trans_state
									  transition_semantic
	   |]


(* ************************************************************************** *)
(* Main *)

let () =
  let j = Yojson.Basic.from_file "unary_sub.json" in
  let data = {name = ""; blank = '0'; initial = ""
			  ; finals = StringSet.empty
			  ; alphabet = None; states = None
			  ; trans_state = ""
			  ; trans_tmp = (0, {read = '0'; to_state = ""; write = '0'; action = Left})
			  ; transitions = TransitionMap.empty
			 } in
  let data = match unfold data file_semantic j with
	| Fail why ->
	   Printf.eprintf "%s\n%!" why;
	   failwith "unfold fail"
	| Success data' -> data'
  in
  print data;
  (* Yojson.Basic.pretty_to_channel ~std:false stdout j; *)
  ()

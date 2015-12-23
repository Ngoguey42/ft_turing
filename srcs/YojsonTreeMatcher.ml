(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonTreeMatcher.ml                               :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 14:04:14 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/23 14:27:16 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

include MonadicTry

type ('a, 'b) func = 'a -> 'b -> 'a status

type 'a node = AssocKnown of (bool * bool * (string, 'a node) Hashtbl.t)
			 | AssocUnknown of (bool * int * ('a, string) func * 'a node)
			 | List of (int * 'a node)
			 | String of ('a, string) func
			 | Int of ('a, int) func
			 | Float of ('a, float) func
			 | Null of ('a, unit) func

let assoc_known ~uniq ~compl fields =
  AssocKnown (uniq, compl, fields)

let assoc_unknown ~uniq ~min ~f entries =
  AssocUnknown (uniq, min, f, entries)

let list ~min entries =
  List (min, entries)


let rec _monoid_fold_left f data l =
  match l with
  | hd::tl -> (match f data hd with
			   | Fail why -> Fail why
			   | Success data' -> _monoid_fold_left f data' tl)
  | _ -> Success data


let (++) = (@@)

let _error fname why json =
  Fail (Printf.sprintf "%s failed because \"%s\" at \"%s\"" fname why
		@@ Yojson.Basic.pretty_to_string json)

let _error2 fname why json json' =
  Fail (Printf.sprintf "%s failed because \"%s\" at \"%s\" in \"%s\"" fname why
		++ Yojson.Basic.pretty_to_string json
		++ Yojson.Basic.pretty_to_string json')


let rec _handle_assoc_known data l (uniq, compl, fields) =
  let llen =  List.length l in
  let uniqlen = List.length @@ List.sort_uniq Pervasives.compare l in (* TODO: Check exactitude lol *)

  if uniq && uniqlen <> llen then
	_error "_handle_assoc_known"
	++ Printf.sprintf "duplicates not allowed by parameter"
	++ `Assoc l

  else if compl && Hashtbl.length fields <> uniqlen then
	_error "_handle_assoc_known"
	++ Printf.sprintf "missing field not allowed by parameter"
	++ `Assoc l

  else _monoid_fold_left (fun data' (str, json') ->
		   let sem' = Hashtbl.find fields str in
		   _aux data' sem' json'
		 ) data l


and _handle_assoc_unknown data l (uniq, min, fn, entries) =
  let llen =  List.length l in

  if uniq && List.length @@ List.sort_uniq Pervasives.compare l <> llen then
	_error "_handle_assoc_unknown"
	++ Printf.sprintf "duplicates not allowed by parameter"
	++ `Assoc l

  else if llen < min then
	_error "_handle_assoc_unknown"
	++ Printf.sprintf "list length to low (%d < %d)" llen min
	++ `Assoc l

  else _monoid_fold_left (fun data' (str, json') ->
		   match fn data' str with
		   | Fail why -> _error2 "_handle_assoc_unknown" why
						 ++ `String str
						 ++ `Assoc l
		   | Success data'' -> _aux data'' entries json'
		 ) data l


and _handle_list data l (min, entries) =
  if List.length l < min then
	_error "_handle_string"
	++ Printf.sprintf "list length to low (%d < %d)" (List.length l) min
	++ `List l

  else _monoid_fold_left (fun data' (json') ->
		   _aux data' entries json'
		 ) data l


and _handle_string data str fn =
  match fn data str with
  | Fail why -> _error "_handle_string" why ++ `String str
  | Success data' -> Success data'

and _handle_int data i fn =
  match fn data i with
  | Fail why -> _error "_handle_string" why ++ `Int i
  | Success data' -> Success data'

and _handle_float data fl fn =
  match fn data fl with
  | Fail why -> _error "_handle_string" why ++ `Float fl
  | Success data' -> Success data'

and _handle_null data fn =
  match fn data () with
  | Fail why -> _error "_handle_string" why ++ `Null
  | Success data' -> Success data'


and _aux data sem json =
  match sem, json with
  | AssocKnown tup,	`Assoc l -> _handle_assoc_known data l tup
  | AssocUnknown tup,	`Assoc l -> _handle_assoc_unknown data l tup
  | List tup,			`List l -> _handle_list data l tup
  | String fn, 		`String s -> _handle_string data s fn
  | Int fn, 			`Int i -> _handle_int data i fn
  | Float fn, 		`Float fl -> _handle_float data fl fn
  | Null fn, 			`Null -> _handle_null data fn

  | AssocKnown _, _ -> Fail "Unmatched assocKnown"
  | AssocUnknown _, _ -> Fail "Unmatched assocUnknown"
  | List _, _ -> Fail "Unmatched list"
  | String _, _ -> Fail "Unmatched string"
  | Int _, _ -> Fail "Unmatched int"
  | Float _, _ -> Fail "Unmatched float"
  | Null _, _ -> Fail "Unmatched null"

let unfold data semantic json =
  _aux data semantic json

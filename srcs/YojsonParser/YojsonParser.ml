(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonParser.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/20 16:25:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/22 20:07:47 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* YojsonTreeMatcher.mli *)
(* Unfolds side by side an ('a node) and a (Yojson.Basic.json)
 *)

module type YOJSONTREEMATCHER = sig
  type 'a status = Fail of string | Success of 'a

  type ('a, 'b) func = 'a -> 'b -> 'a status

  type 'a node = AssocKnown of (bool * bool * (string, 'a node) Hashtbl.t)
			   | AssocUnknown of (bool * int * ('a, string) func * 'a node)
			   | List of (int * 'a node)
			   | String of ('a, string) func
			   | Int of ('a, int) func
			   | Float of ('a, float) func
			   | Null of ('a, unit) func

  val assoc_known :
	uniq:bool -> compl:bool -> (string, 'a node) Hashtbl.t -> 'a node

  val assoc_unknown :
	uniq:bool -> min:int -> f:('a, string) func -> 'a node -> 'a node

  val list : min:int -> 'a node -> 'a node

  val unfold : 'a -> 'a node -> Yojson.Basic.json -> 'a status

end

(* ************************************************************************** *)
(* YojsonTreeMatcher.ml *)

module YojsonTreeMatcher : YOJSONTREEMATCHER = struct
  type 'a status = Fail of string | Success of 'a

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

end


(* ************************************************************************** *)
(* Action.mli *)

module type ACTION = sig
  type action = Left | Right
end

(* ************************************************************************** *)
(* Action.ml *)
module Action : ACTION = struct
  type action = Left | Right
end

(* ************************************************************************** *)
(* ProgramDataTmp.mli *)

module type PROGRAMDATATMP = sig

  module StringSet : Set.S with type elt = string
  module CharSet : Set.S with type elt = char
  module TransitionMap : Map.S with type key = string * char

  type transition_data = {
	  read : char;
	  to_state : string;
	  write : char;
	  action : Action.action;
	}
  type parsing_data = {
	  name : string;
	  blank : char;
	  initial : string;
	  finals : StringSet.t;
	  alphabet : CharSet.t option;
	  states : StringSet.t option;
	  trans_state : string;
	  trans_tmp : int * transition_data;
	  transitions : transition_data TransitionMap.t;
	}
  val print : parsing_data -> unit
  val default : parsing_data

end

(* ************************************************************************** *)
(* ProgramDataTmp.ml *)

module ProgramDataTmp : PROGRAMDATATMP = struct

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
	Printf.eprintf "n:'%s' c:'%c' i:'%s' f:[%s] \nalpha:%s \nstates:%s\n%s\n%!"
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

end


(* ************************************************************************** *)
(* ProgramCreator.mli *)

module type PROGRAMCREATOR = sig
  val file_semantic : ProgramDataTmp.parsing_data YojsonTreeMatcher.node
end

(* ************************************************************************** *)
(* ProgramCreator.ml *)

module ProgramCreator : PROGRAMCREATOR= struct

  include Action
  include ProgramDataTmp
  include YojsonTreeMatcher

  let _save_name db name =
	Success {db with name}

  let _save_letter ({alphabet} as db) str =
	if String.length str <> 1 then
	  Fail "String.length str <> 1"
	else (
	  let c = String.get str 0 in
	  match alphabet with
	  | None -> Success {db with alphabet = Some (CharSet.add c CharSet.empty)}
	  | Some set when CharSet.mem c set -> Fail "Duplicate in alphabet"
	  | Some set -> Success {db with alphabet = Some (CharSet.add c set)}
	)

  let _save_blank ({alphabet} as db) str =
	if String.length str <> 1 then
	  Fail "String.length str <> 1"
	else (
	  let c = String.get str 0 in
	  match alphabet with
	  | None -> Fail "alphabet not defined"
	  | Some set when not (CharSet.mem c set) -> Fail "Not present in alphabet"
	  | _ -> Success {db with blank = c}
	)

  let _save_state ({states} as db) str =
	match states with
	| None -> Success {db with states = Some (StringSet.add str StringSet.empty)}
	| Some set when StringSet.mem str set -> Fail "Duplicate in states"
	| Some set -> Success {db with states = Some (StringSet.add str set)}

  let _save_initial ({states} as db) str =
	match states with
	| None -> Fail "states not defined"
	| Some set when not (StringSet.mem str set) -> Fail "Not present in states"
	| _ -> Success {db with initial = str}

  let _save_finals ({states; finals} as db) str =
	match states with
	| None -> Fail "states not defined"
	| Some set when not (StringSet.mem str set) -> Fail "Not present in states"
	| Some set when StringSet.mem str finals -> Fail "Duplicate in finals"
	| _ -> Success {db with finals = StringSet.add str finals}


  let _save_trans_state ({states} as db) str =
	match states with
	| None -> Fail "states not defined"
	| Some set when not (StringSet.mem str set) -> Fail "Not present in states"
	| _ -> Success {db with trans_state = str}

  let _save_transition ({trans_tmp = (_, record); transitions; trans_state}
						as db) trans =
	let tr = TransitionMap.add (trans_state, trans.read) trans transitions in
	Success {db with trans_tmp = (0, record); transitions = tr }

  let _save_trans_read ({trans_tmp; alphabet} as db) str =
	if String.length str <> 1 then
	  Fail "String.length str <> 1"
	else (
	  let c = String.get str 0 in
	  match alphabet with
	  | None -> Fail "alphabet not defined"
	  | Some set when not (CharSet.mem c set) -> Fail "Not present in alphabet"
	  | _ -> let count, dat = trans_tmp in
			 let dat = {dat with read = c} in
			 if count = 3 then
			   _save_transition db dat
			 else
			   Success {db with trans_tmp = (count + 1, dat)}
	)

  let _save_trans_write ({trans_tmp; alphabet} as db) str =
	if String.length str <> 1 then
	  Fail "String.length str <> 1"
	else (
	  let c = String.get str 0 in
	  match alphabet with
	  | None -> Fail "alphabet not defined"
	  | Some set when not (CharSet.mem c set) -> Fail "Not present in alphabet"
	  | _ -> let count, dat = trans_tmp in
			 let dat = {dat with write = c} in
			 if count = 3 then
			   _save_transition db dat
			 else
			   Success {db with trans_tmp = (count + 1, dat)}
	)

  let _save_trans_to_state ({trans_tmp; states} as db) str =
	match states with
	| None -> Fail "state not defined"
	| Some set when not (StringSet.mem str set) -> Fail "Not present in state"
	| _ -> let count, dat = trans_tmp in
		   let dat = {dat with to_state = str} in
		   if count = 3 then
			 _save_transition db dat
		   else
			 Success {db with trans_tmp = (count + 1, dat)}

  let _save_trans_action ({trans_tmp; states} as db) str =
	let action = match str with
	  | "LEFT" -> Some Left
	  | "RIGHT" -> Some Right
	  | _ -> None
	in
	match action with
	| Some action ->  let count, dat = trans_tmp in
					  let dat = {dat with action} in
					  if count = 3 then
						_save_transition db dat
					  else
						Success {db with trans_tmp = (count + 1, dat)}
	| None -> Fail "Undefined action"


  (* ~| Hashtbl constructor from array *)
  let (~|) : ('a * 'b) array -> ('a, 'b) Hashtbl.t = fun a ->
	let ht = Hashtbl.create @@ Array.length a in
	Array.iter (fun (k, v) -> Hashtbl.add ht k v) a;
	ht

  let _transition_semantic =
	list ~min:0
	@@ assoc_known ~uniq:true ~compl:true
	@@ ~| [|
		   "read", String _save_trans_read
		 ; "to_state", String _save_trans_to_state
		 ; "write", String _save_trans_write
		 ; "action", String _save_trans_action
		 |]

  let file_semantic =
	assoc_known ~uniq:true ~compl:true
	@@ ~| [|
		   "name", String _save_name
		 ; "alphabet" , list ~min:1 (String _save_letter)
		 ; "blank", String _save_blank

		 ; "initial", String _save_initial
		 ; "states" , list ~min:1 (String _save_state)
		 ; "finals", list ~min:1 (String _save_finals)
		 ; "transitions", assoc_unknown ~uniq:true ~min:0 ~f:_save_trans_state
										_transition_semantic
		 |]
end

(* ************************************************************************** *)
(* Main *)

let () =
  let j = Yojson.Basic.from_file "unary_sub.json" in
  let data = ProgramDataTmp.default in
  let data = match YojsonTreeMatcher.unfold data ProgramCreator.file_semantic j with
	| YojsonTreeMatcher.Fail why ->
	   Printf.eprintf "%s\n%!" why;
	   failwith "unfold fail"
	| YojsonTreeMatcher.Success data' -> data'
  in
  ProgramDataTmp.print data;
  (* Yojson.Basic.pretty_to_channel ~std:false stdout j; *)
  ()

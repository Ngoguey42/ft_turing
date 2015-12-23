include Action
include MonadicTry
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

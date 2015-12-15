(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 13:58:38 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/15 17:53:56 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* LoopGuard searches for recurrences in successive states.
 * type t must be exhaustive while representing a state.
 *)

module Make =
  functor (State : sig
			  type t
			  val hash : t -> int
			  val equal : t -> t -> bool
			  val tostring : t -> string
			end) ->
  (* functor (State : Hashtbl.HashedType) -> *)
  struct

	type seq = State.t list
	type seqs = {
		prevseq	: seq option;
		curseq	: seq;
	  }

	module StateHtbl = Hashtbl.Make(State)

	let ht = StateHtbl.create 128

	let _resetStateSequences key {curseq = csq} =

	  StateHtbl.replace ht key {prevseq = Some csq
							   ;curseq = []}

	let _insertStateInSequence st key ({curseq = csq} as value) =

	  StateHtbl.replace ht key {value with
								 curseq = st::csq}


	let _sequencesEqual a b =

	  if List.length a <> List.length b then
		false
	  else if List.fold_left2
				(fun bool a' b' -> if bool = false || (State.equal a' b') = false then false else true)
				true a b then
		true
	  else
		false


	let _update curState st ({ prevseq = psq
							 ; curseq = csq } as entry) =

	  if State.equal curState st
	  then (
		match psq with
		| Some psq' when _sequencesEqual csq psq'	->
		   Printf.eprintf "\tFaile %s\n%!" (State.tostring st);
		   Printf.eprintf "[%!";
		   List.iter (fun v ->
			   Printf.eprintf "%2s;" (State.tostring v)) csq;
		   Printf.eprintf "]\n%!";
		   Printf.eprintf "[%!";
		   List.iter (fun v ->
			   Printf.eprintf "%2s;" (State.tostring v)) psq';
		   Printf.eprintf "]\n%!";
		   failwith "Loop detected, implement suitable error"
		| _											->
		   Printf.eprintf "\tReset %s\n%!" (State.tostring st);
		   _resetStateSequences st entry
	  )
	  else (
		Printf.eprintf "\tUpdat %s\n%!" (State.tostring st);
		_insertStateInSequence curState st entry
	  )

	let update curState =

	  let tmp = {
				prevseq = None
				;curseq = []} in
	  StateHtbl.iter (_update curState) ht;
	  if not (StateHtbl.mem ht curState) then (
		Printf.eprintf "\tInser %s\n%!" (State.tostring curState);
		StateHtbl.add ht curState tmp
	  )
  end

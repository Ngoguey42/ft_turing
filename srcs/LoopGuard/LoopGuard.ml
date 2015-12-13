(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 13:58:38 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/13 16:08:09 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make =
  functor (State : Hashtbl.HashedType) ->
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
				(fun bool a' b' -> if bool then true else State.equal a' b')
				true a b then
		true
	  else
		false


	let _update curState st ({
							prevseq = psq
							;curseq = csq} as entry) =

	  if State.equal curState st
	  then (
		match psq with
		| Some psq' when _sequencesEqual csq psq'	->
		   Printf.eprintf "\tFailed\n%!";
		   failwith "Loop detected, implement suitable error"
		| _											->
		   Printf.eprintf "\tResetting\n%!";
		   _resetStateSequences st entry
	  )
	  else (
		Printf.eprintf "\tUpdating \n%!";
		_insertStateInSequence curState st entry
	  )

	let update curState =

	  let tmp = {
				prevseq = None
				;curseq = []} in
	  StateHtbl.iter (_update curState) ht;
	  if not (StateHtbl.mem ht curState) then (
		Printf.eprintf "\tInserting\n%!";
		StateHtbl.add ht curState tmp
	  )
  end

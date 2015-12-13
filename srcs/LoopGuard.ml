(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 13:58:38 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/13 15:38:36 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make =
  functor (State : Hashtbl.HashedType) ->
  struct

	module StateSequences =
	  struct

		type seq = State.t list
		type t = {
			start	: State.t;
			prevseq	: seq option;
			curseq	: seq;
		  }

		let equal {start = a} {start = b} =
		  State.equal a b

		let hash {start = a} =
		  State.hash a

	  end

	module StateHtbl = Hashtbl.Make(StateSequences)

	let ht = StateHtbl.create 128

	let _resetStateSequences ({StateSequences.curseq = csq} as entry) =
	  StateHtbl.replace ht entry {entry with
								   StateSequences.prevseq = Some csq
								  ;StateSequences.curseq = []}

	let _insertStateInSequence st ({StateSequences.curseq = csq} as entry) =
	  StateHtbl.replace ht entry {entry with
								   StateSequences.curseq = st::csq}


	let _sequencesEqual a b =
	  if List.length a <> List.length b then
		false
	  else if List.fold_left2
				(fun bool a' b' -> if bool then true else State.equal a' b')
				true a b then
		true
	  else
		false


	let _update curState _ ({StateSequences.start = st
							;StateSequences.prevseq = psq
							;StateSequences.curseq = csq} as entry) =

	  if State.equal curState st
	  then (
		match psq with
		| Some psq' when _sequencesEqual csq psq'	->
		   failwith "Loop detected, implement suitable error"
		| _											->
		   _resetStateSequences entry
	  )
	  else
		_insertStateInSequence curState entry


	let update curState =
	  StateHtbl.iter (_update curState) ht

  end

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 13:58:38 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/17 18:38:44 by ngoguey          ###   ########.fr       *)
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

	type htelt = {
		llast		: int option;
		last		: int;
	  }
	type dqelt = {
		claimed		: bool;
		state		: State.t;
	  }

	module StateHtbl = Hashtbl.Make(State)
	let ht = StateHtbl.create 128
	let dq = Core.Dequeue.create ~initial_length:128 ~never_shrink:false ()

	let rec _dq_count_unclaimed_toward_back i acc =
	  match Core.Dequeue.get dq i with
	  | {claimed = true} ->
		 acc
	  | _ ->
		 _dq_count_unclaimed_toward_back (i + 1) (acc + 1)

	let rec _dq_range_equal a b bend =
	  if b = bend
	  then true
	  else if Core.Dequeue.get dq a = Core.Dequeue.get dq b
	  then _dq_range_equal (a + 1) (b + 1) bend
	  else false


	let _isLoop llast last backi =
	  if llast - last <> last - backi
	  then false
	  else if _dq_range_equal llast last backi
	  then true
	  else false


	let update curState =
	  Core.Dequeue.enqueue_back dq { claimed = true; state = curState };
	  let backi = Core.Dequeue.back_index_exn dq in

	  if StateHtbl.mem ht curState then (
		let {llast; last} = StateHtbl.find ht curState in
		let fronti = Core.Dequeue.front_index_exn dq in

		(match llast with
		| Some llast' when _isLoop llast' last backi ->
		   failwith "Loop detected, implement suitable error"
		| Some llast' when llast' = fronti ->
		   let count = _dq_count_unclaimed_toward_back (fronti + 1) 1 in
		   Printf.eprintf "\tdropping %delements %dleft\n%!" count (backi - fronti + 1 - count);
		   Core.Dequeue.drop_front dq ~n:count
		   ()
		| Some llast' ->
		   Core.Dequeue.set_exn dq llast' {claimed = false; state = curState}
		| _ ->
		   ()
		);
		StateHtbl.replace ht curState { llast = Some last; last = backi }
	  )
	  else (
		(* Printf.eprintf "\tInser %s\n%!" (State.tostring curState); *)
		StateHtbl.add ht curState { llast = None
								  ; last = backi }
	  )
	  ;
  end

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 13:58:38 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/19 12:05:26 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* LoopGuard searches for recurrences in successive states.
 * type t must be exhaustive when representing states.
 * Core.dequeue(dq) stores successive states (Enqueued back)
 * Hashtbl(ht) stores states' 2 latests indices in dq
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
	let _ht_initlen = 1024
	let _dq_initlen = _ht_initlen * 3

	let _ht = StateHtbl.create _ht_initlen
	let _dq = Core.Dequeue.create
				~initial_length:_dq_initlen ~never_shrink:false ()

	(* Garbage collect helper *)
	let rec _dq_count_unclaimed_toward_back : int -> int -> int = fun i acc ->
	  match Core.Dequeue.get _dq i with
	  | {claimed = true} ->
		 acc
	  | _ ->
		 _dq_count_unclaimed_toward_back (i + 1) (acc + 1)

	(* Loop Detection helper 2/2 *)
	let rec _dq_range_equal : int -> int -> int -> bool = fun a b bend ->
	  if b = bend
	  then true
	  else if Core.Dequeue.get _dq a = Core.Dequeue.get _dq b
	  then _dq_range_equal (a + 1) (b + 1) bend
	  else false

	(* Loop Detection helper 1/2 *)
	let _isLoop : (int * int * int) -> bool = fun (llast, last, backi) ->
	  if llast - last <> last - backi
	  then false
	  else if _dq_range_equal llast last backi
	  then true
	  else false

	(* Update deque according to llast
	 * Case1:	Loop Detected
	 * Case2:	dq Garbage collection
	 * Case3:	Tag dq[i] for future Garbage collection
	 * Case4:	Nothing
	 *)
	let _dq_update : State.t -> (int option * int * int) ->
					 unit = fun curState (llast, last, backi) ->
	  let fronti = Core.Dequeue.front_index_exn _dq in

	  match llast with
	  | Some llast' when _isLoop (llast', last, backi) ->
		 failwith "Loop detected, implement suitable error"
	  | Some llast' when llast' = fronti ->
		 let (/>) : 'a -> (?n:int -> 'b) -> 'b = fun n f -> f ~n in
		 _dq_count_unclaimed_toward_back (fronti + 1) 1
		 /> Core.Dequeue.drop_front
		 @@ _dq;
		 ()
	  | Some llast' ->
		 Core.Dequeue.set_exn _dq llast' {claimed = false; state = curState}
	  | _ ->
		 ()


	let update : State.t -> unit = fun curState ->
	  Core.Dequeue.enqueue_back _dq { claimed = true; state = curState };
	  let backi = Core.Dequeue.back_index_exn _dq in

	  if StateHtbl.mem _ht curState then (
		let {llast; last} = StateHtbl.find _ht curState in

		_dq_update curState (llast, last, backi);
		StateHtbl.replace _ht curState { llast = Some last; last = backi }
	  )
	  else (
		(* Printf.eprintf "\tInser %s\n%!" (State.tostring curState); *)
		StateHtbl.add _ht curState { llast = None; last = backi }
	  )
	  ;
  end

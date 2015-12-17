(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 13:58:38 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/17 17:29:27 by ngoguey          ###   ########.fr       *)
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
		llast			: int option;
		last			: int;
	  }
	type dqelt = {
		mutable claimed	: bool;
		state			: State.t;
	  }

	module StateHtbl = Hashtbl.Make(State)
	let ht = StateHtbl.create 128
	let dq = Core.Dequeue.create ~initial_length:128 ~never_shrink:false ()

	let update curState =
	  Core.Dequeue.enqueue_back dq { claimed = true; state = curState };
	  if StateHtbl.mem ht curState then
	  	Printf.eprintf "hello\n%!"
	  else
		StateHtbl.add ht curState { llast = None
								  ; last = Core.Dequeue.back_index_exn dq}
	  ;
		(* let _insertHashtbl curState = *)
		(* _insertHashtbl curState; *)
	  (* let tmp = { *)
	  (* 	  llast = None; *)
	  (* 	  last = 42; *)
	  (* 	} in *)
	  (* StateHtbl.add ht curState tmp; *)
	  ()
  end

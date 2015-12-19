(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   SecuredHashtbl.ml                                  :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/19 15:46:48 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/19 15:48:18 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Wrapper over Hashtbl for secured and verbose add operations
 *)

(*      Is a functor with private functions/variables the same as a
 *  statically instanciated class?
 *)

module Make =
  functor (Couple : sig
			  type tk
			  type tv
			  include Hashtbl.HashedType with type t = tk

			  val key_invariants : (string * (tk -> bool)) array
			  val val_invariants : (string * (tv -> bool)) array
			  val ktostring : tk -> string
			  val vtostring : tv -> string
			end) ->
  struct

	module CoupleHtbl = Hashtbl.Make(Couple)
	let _ht : Couple.tv CoupleHtbl.t = CoupleHtbl.create 128

	let _key_redundant_error : Couple.tk -> unit = fun k ->
	  Couple.ktostring k
	  |> Printf.sprintf "Key \"%s\" showed up twice"
	  |> failwith

	let _key_invariant_error : Couple.tk -> string -> unit = fun k name ->
	  Couple.ktostring k
	  |> Printf.sprintf "Invariant \"%s\" failed for key = \"%s\"" name
	  |> failwith

	let _val_invariant_error : Couple.tv -> string -> unit = fun v name ->
	  Couple.vtostring v
	  |> Printf.sprintf "Invariant \"%s\" failed for value = \"%s\"" name
	  |> failwith

	let add : Couple.tk -> Couple.tv -> unit = fun k v ->
	  if CoupleHtbl.mem _ht k then
		_key_redundant_error k;
	  Array.iter
		(fun (name, f) -> if f k = false then _key_invariant_error k name)
		Couple.key_invariants;
	  Array.iter
		(fun (name, f) -> if f v = false then _val_invariant_error v name)
		Couple.val_invariants;
	  CoupleHtbl.add _ht k v;
	  ()

	let find : Couple.tk -> Couple.tv = fun k ->
	  CoupleHtbl.find _ht k

  end

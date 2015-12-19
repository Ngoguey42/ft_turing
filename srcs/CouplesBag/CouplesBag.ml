(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   CouplesBag.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/19 14:37:04 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/19 14:37:04 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(*      Is a functor with private functions/variables the same as a
 *  statically instanciated class?
 *)

let (/>) = Pervasives.(|>)

module Make =
  functor (Couple : sig
			  type tk
			  type tv
			  include Hashtbl.HashedType with type t = tk

			  val key_invariants : (tk -> bool) array
			  val val_invariants : (tv -> bool) array
			  val ktostring : tk -> string
			  val vtostring : tv -> string
			end) ->
  struct


	module CoupleHtbl = Hashtbl.Make(Couple)
	let ht : Couple.tv CoupleHtbl.t = CoupleHtbl.create 128

	let _key_invariant_error : Couple.tk -> int -> unit = fun k i ->
	  Couple.ktostring k
	  |> Printf.sprintf "Invariant #%d failed for key = \"%s\"" i
	  |> failwith

	let _val_invariant_error : Couple.tv -> int -> unit = fun v i ->
	  Couple.vtostring v
	  |> Printf.sprintf "Invariant #%d failed for value = \"%s\"" i
	  |> failwith

	let insert_couple : Couple.tk -> Couple.tv -> unit = fun k v ->

	  (fun i f -> if f k = false then _key_invariant_error k i)
	  /> Array.iteri
	  @@ Couple.key_invariants;
	  (fun i f -> if f v = false then _val_invariant_error v i)
	  /> Array.iteri
	  @@ Couple.val_invariants;

	  ()


  end

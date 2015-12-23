(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   YojsonTreeMatcher.mli                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 14:04:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/23 14:27:06 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Unfolds side by side an ('a node) and a (Yojson.Basic.json)
 *)

type ('a, 'b) func = 'a -> 'b -> 'a MonadicTry.status

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

val unfold : 'a -> 'a node -> Yojson.Basic.json -> 'a MonadicTry.status

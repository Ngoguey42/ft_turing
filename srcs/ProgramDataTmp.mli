(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ProgramDataTmp.mli                                 :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 14:03:29 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/23 14:23:55 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module StringSet : Set.S with type elt = string
module CharSet : Set.S with type elt = char
module TransitionMap : Map.S with type key = string * char

type transition_data = {
	read : char;
	to_state : string;
	write : char;
	action : Action.action;
  }

type parsing_data = {
	name : string;
	blank : char;
	initial : string;
	finals : StringSet.t;
	alphabet : CharSet.t option;
	states : StringSet.t option;
	trans_state : string;
	trans_tmp : int * transition_data;
	transitions : transition_data TransitionMap.t;
  }

val print : parsing_data -> unit
val default : parsing_data

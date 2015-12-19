(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   StatesBag.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/19 15:50:35 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/19 17:15:33 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type action = Left | Right

(* Work in progress. Might remove this file later *)

type input = Name of string
		   | Alphabet of string
		   | Blank of string
		   | State of string
		   | Initial of string
		   | Final of string
		   | Transition of string * string * string * string * action


module AlphabetCouple = struct
  type tk = string
  type tv = unit
  type t = tk

  include SecuredHashtbl.DefaultCouple
  let key_invariants = [|
	  ("Length = 1", (fun s -> String.length s = 1))
	|]
  let ktostring k = Printf.sprintf "%s" k
  let name = "Alphabet"
end
module AlphabetHashtbl = SecuredHashtbl.Make(AlphabetCouple)


module StateCouple = struct
  type tk = string
  type tv = unit
  type t = tk

  include SecuredHashtbl.DefaultCouple
  let ktostring k = Printf.sprintf "%s" k
  let name = "State"
end
module StateHashtbl = SecuredHashtbl.Make(StateCouple)


module FinalCouple = struct
  type tk = string
  type tv = unit
  type t = tk

  include SecuredHashtbl.DefaultCouple
  let key_invariants = [|
	  ("State exists", (fun stt -> StateHashtbl.mem stt))
	|]
  let ktostring k = Printf.sprintf "%s" k
  let name = "Final"
end
module FinalHashtbl = SecuredHashtbl.Make(FinalCouple)


module TransitionCouple = struct
  type tk = string * string
  type tv = string * string * action
  type t = tk
  include SecuredHashtbl.DefaultCouple

  let key_invariants = [|
	  ("State exists", (fun (stt, _) -> StateHashtbl.mem stt))
	; ("Character exists", (fun (_, chr) -> AlphabetHashtbl.mem chr))
	|]
  let val_invariants = [|
	  ("State exists", (fun (stt, _, _) -> StateHashtbl.mem stt))
	; ("Character exists", (fun (_, chr, _) -> AlphabetHashtbl.mem chr))
	|]
  let ktostring (stt, chr) = Printf.sprintf "%s/%s" stt chr
  let vtostring (stt, chr, act) =
	Printf.sprintf "%s/%s/%s" stt chr
	@@ match act with Left -> "Left" | Right -> "Right"
  let name = "Transition"
end
module TransitionHashtbl = SecuredHashtbl.Make(TransitionCouple)

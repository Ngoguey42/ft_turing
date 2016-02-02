(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   StringListTickTock.ml                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/02 16:46:08 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/02 18:07:02 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Tick Tock strings lists *)

type t = {
	strings : string list array;
	mutable phase : int
  }

let empty tasks =
  match tasks.strings.(0), tasks.strings.(1) with
  | [], [] -> true
  | _, _ -> false

let create str =
  {strings = [|[str]; []|]; phase = 0}

(** Add a string to ((tsks.phase + 1) % 2) array *)
let add tsks str =
  let arr_index = (tsks.phase + 1) mod 2 in
  tsks.strings.(arr_index) <- str::tsks.strings.(arr_index);
  ()

(** Pop a string
 ** - from (tsks.phase % 2) array
 ** - or increment tsks.phase
 **     and pop a string from (tsks.phase % 2) array
 ** - or raise *)
let pop tsks =
  let arr_index = tsks.phase mod 2 in
  match tsks.strings.(arr_index) with
  | hd::tl -> tsks.strings.(arr_index) <- tl;
			  hd
  | _ -> tsks.phase <- tsks.phase + 1;
		 let arr_index = tsks.phase mod 2 in
		 match tsks.strings.(arr_index) with
		 | hd::tl -> tsks.strings.(arr_index) <- tl;
					 hd
		 | _ -> failwith "Empty tick tock"

let phase {phase} =
  phase

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   StringListTickTock.ml                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/02 16:46:08 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/02 17:21:44 by ngoguey          ###   ########.fr       *)
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

let create () =
  {strings = [|[]; []|]; phase = 0}

(** Add a string to phase' *)
let add tsks str =
  let arr_index = (tsks.phase + 1) mod 2 in
  Printf.eprintf "+\"%s\" to .(%d)\n%!" str arr_index;
  tsks.strings.(arr_index) <- str::tsks.strings.(arr_index);
  ()

(** Pop a string from tsks.phase
 ** or from tsks.phase' and increment tsks.phase
 ** or raise *)
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

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 15:28:54 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/06 14:36:20 by fbuoro           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module LoopGuard =
  LoopGuard.Make(
	  struct
		type t = int * char * int
		let hash = Hashtbl.hash
		let equal = (=)
		let tostring (i, c, st) =
		  Printf.sprintf "index(%d) read(%c) state(%d)"
						 i c st;
	  end)

let rec loop db tape statei =
  let read = Tape.head tape in
  Tape.print tape;
  LoopGuard.update (Tape.index tape, read, statei);
  match ProgramData.transition db statei read with
  | ProgramData.Undefined ->
	 failwith "Undefined char or transition"
  | ProgramData.Final -> ()
  | ProgramData.Normal (write, action, next) ->
	 loop db (Tape.action tape write action) next

let () =
  match Arguments.read () with
  | Arguments.Exec (jsonfile, input) ->
	 let db = ProgramData.of_jsonfile jsonfile in
	 ProgramData.print db;
	 let tape = Tape.of_string input db.ProgramData.blank in
	 loop db tape db.ProgramData.initial
  | Arguments.Convert jsonfile -> Convert.output jsonfile

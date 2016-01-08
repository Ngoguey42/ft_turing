(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 15:28:54 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/08 14:04:13 by ngoguey          ###   ########.fr       *)
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

let (++) = (@@)

let rec loop db tape statei i =
  let read = Tape.head tape in
  let tapei = Tape.index tape in
  Tape.print tape;
  Printf.printf "\t(i%d)[%s]#%d\n" tapei
  ++ ProgramData.state_name db statei
  ++ i;
  LoopGuard.update (tapei, read, statei);
  match ProgramData.transition db statei read with
  | ProgramData.Undefined ->
	 failwith "Undefined char or transition"
  | ProgramData.Final -> ()
  | ProgramData.Normal (write, action, next) ->
	 loop db (Tape.action tape write action) next (i + 1)

let () =
  match Arguments.read () with
  | Arguments.Exec (jsonfile, input) ->
	 let db = ProgramData.of_jsonfile jsonfile in
	 ProgramData.print db;
	 let tape = Tape.of_string input db.ProgramData.blank in
	 loop db tape db.ProgramData.initial 1
  | Arguments.Convert jsonfile -> Convert.output jsonfile

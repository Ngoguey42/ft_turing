(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 15:28:54 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/19 16:38:38 by ngoguey          ###   ########.fr       *)
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

let dump (tape, tapei, db, statei, i) =
  Tape.print tape;
  Printf.printf "\t(i%d)[%s]#%d\n" tapei
  ++ ProgramData.state_name db statei
  ++ i

let rec loop db tape statei i silent =
  let read = Tape.head tape in
  let tapei = Tape.index tape in
  if not silent
  then dump (tape, tapei, db, statei, i);
  (* LoopGuard.update (tapei, read, statei); *)
  match ProgramData.transition db statei read with
  | ProgramData.Undefined ->
	 failwith "Undefined char or transition"
  | ProgramData.Final ->
	 Printf.printf "\n%!";
	 dump (tape, tapei, db, statei, i)
  | ProgramData.Normal (write, action, next) ->
	 loop db (Tape.action tape write action) next (i + 1) silent

let catfile filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = really_input_string chan len in
  close_in chan;
  str

let () =
  match Arguments.read () with
  | Arguments.Exec (jsonfile, input, silent, fileinput) ->
	 let input = match fileinput with false -> input | true -> catfile input in
	 let db = ProgramData.of_jsonfile jsonfile in
	 ProgramData.print db;
	 let tape = Tape.of_string input db.ProgramData.blank in
	 loop db tape db.ProgramData.initial 1 silent;
	 ()
  | Arguments.Convert (jsonfile, input, fileinput) ->
	 let input = match fileinput with false -> input | true -> catfile input in
	 Convert.output jsonfile input

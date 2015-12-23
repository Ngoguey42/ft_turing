(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 15:28:54 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/23 17:47:01 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module LoopGuard = LoopGuard.Make(
					   struct
						 type t = int * char * int
						 let hash = Hashtbl.hash
						 let equal = (=)
						 let tostring (i, c, st) =
						   Printf.sprintf "index(%d) read(%c) state(%d)"
						 				  i c st;
					   end)

let rec loop db tape statei =
  Tape.print tape;
  let read = Tape.head tape in
  LoopGuard.update (Tape.index tape, read, statei);
  match ProgramData.transition db statei read with
  | ProgramData.Undefined -> failwith "Undefined char or transition"
  | ProgramData.Final -> failwith "Final"
  | ProgramData.Normal (write, action, next) ->
	 loop db (Tape.action tape write action) next


let () =
  let j = Yojson.Basic.from_file "unary_sub.json" in
  let data = ProgramDataTmp.default in
  let data = match YojsonTreeMatcher.unfold data YojsonTree.file_semantic j with
	| MonadicTry.Fail why ->
	   Printf.eprintf "%s\n%!" why;
	   failwith "unfold fail"
	| MonadicTry.Success data' -> data'
  in
  ProgramDataTmp.print data;
  Printf.eprintf "\n%!";
  let db = ProgramData.create data in
  ProgramData.print db;
  Printf.eprintf "input: %s\n%!" Sys.argv.(1);
  let tape = Tape.of_string Sys.argv.(1) db.ProgramData.blank in
  ignore(loop db tape db.ProgramData.initial);
  (* Yojson.Basic.pretty_to_channel ~std:false stdout j; *)
  ()

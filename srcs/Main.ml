(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/23 15:28:54 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/23 15:30:17 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let () =
  let j = Yojson.Basic.from_file "unary_sub.json" in
  let data = ProgramDataTmp.default in
  let data = match YojsonTreeMatcher.unfold data ProgramCreator.file_semantic j with
	| MonadicTry.Fail why ->
	   Printf.eprintf "%s\n%!" why;
	   failwith "unfold fail"
	| MonadicTry.Success data' -> data'
  in
  ProgramDataTmp.print data;
  Printf.eprintf "\n%!";
  let db = ProgramData.create data in
  ProgramData.print db;
  (* Yojson.Basic.pretty_to_channel ~std:false stdout j; *)
  ()

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Verifier.ml                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:01:04 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/30 16:59:52 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = Member of int
	   | Not of int

let rec loop db tape statei i =
  let read = Tape.head tape in
  (* let tapei = Tape.index tape in *)
  match ProgramData.transition db statei read with
  | ProgramData.Undefined -> Not i
  | ProgramData.Final -> Member i
  | ProgramData.Normal (write, action, next) ->
	 loop db (Tape.action tape write action) next (i + 1)

let verify db input =
  let tape = Tape.of_string input db.ProgramData.blank in
  loop db tape db.ProgramData.initial 1

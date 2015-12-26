(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Convert.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/26 14:46:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/26 18:49:29 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

include Action

let (++) = (@@)

let _trans_to_input (str, i) trans =
  match trans with
  | ProgramData.Normal (write, act, next) ->
	 (Printf.sprintf "%s=%s=%s=%c%cu"
	  ++ str
	  ++ String.make (next + 1) '1'
	  ++ (match act with Left -> "0" | Right -> "1")
	  ++ write
	  ++ char_of_int i
	 , i + 1)
  | _ -> (str, i + 1)

let _transs_to_input transarr =
  let transstr, _ = Array.fold_left _trans_to_input ("", 0) transarr in
  transstr

let _state_to_input (str, i) (_, transarr) =
  (Printf.sprintf "%s=%s=%c=%su"
   ++ str
   ++ _transs_to_input transarr
   ++ (match transarr.(0) with ProgramData.Final -> '1' | _ -> '0')
   ++ String.make (i + 1) '1'
  , i + 1)

let _states_to_input {ProgramData.states; ProgramData.initial} =
  let statestr, _ = Array.fold_left _state_to_input ("", 0) states in
  statestr

let _buffer_to_input {ProgramData.states; ProgramData.initial} =
  let breg = String.make (Array.length states + 2) '0' in
  Printf.sprintf "%s=%s=%c%c"
  ++ breg
  ++ String.mapi (fun i _ -> if i <= initial then '1' else '0') breg
  ++ '0'
  ++ '0'

let output jsonfile =
  let db = ProgramData.of_jsonfile jsonfile in
  Printf.printf "=%s%s="
  ++ _states_to_input db
  ++ _buffer_to_input db

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Convert.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/26 14:46:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/11 18:06:02 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

include Action

let (++) = (@@)
let i'm_lazy_right_now = ref '0'

let _val_to_binary i =
  if i == 0 then
	"0"
  else (
	let rec aux i str =
	  if i == 0
	  then str
	  else if i mod 2 == 0
	  then aux (i / 2) @@ Printf.sprintf "%c%s" '0' str
	  else aux (i / 2) @@ Printf.sprintf "%c%s" '1' str
	in
	aux i ""
  )

let _trans_to_input (str, i) trans =
  match trans with
  |  ProgramData.Normal (write, act, next) ->
	  (let wisblank = write == !i'm_lazy_right_now in
	   let risblank = (char_of_int i) == !i'm_lazy_right_now in
	   Printf.sprintf "%s-%s=%s%c%s%c%su"
	   ++ str
	   ++ _val_to_binary next
	   ++ (match act with Left -> "0" | Right -> "1")
	   ++ (match wisblank with true -> '1' | false -> write)
	   ++ (match wisblank with true -> "1" | false -> "0")
	   ++ (match risblank with true -> '1' | false -> char_of_int i)
	   ++ (match risblank with true -> "1" | false -> "0")
	   , i + 1)
  | _ -> (str, i + 1)

let _transs_to_input transarr =
  let transstr, _ = Array.fold_left _trans_to_input ("", 0) transarr in
  transstr

let _state_to_input (str, i) (_, transarr) =
  (Printf.sprintf "%s+%s=%s=%cu"
   ++ str
   ++ _transs_to_input transarr
   ++ _val_to_binary i
   ++ (match transarr.(0) with ProgramData.Final -> '1' | _ -> '0')
  (* ++ String.make (i + 1) '1' *)
  (* ++ String.make (i + 1) '1' *)
  , i + 1)

let _states_to_input {ProgramData.states; ProgramData.initial} =
  let statestr, _ = Array.fold_left _state_to_input ("", 0) states in
  statestr

let _buffer_to_input {ProgramData.states; ProgramData.initial} =
  let flen = log (float @@ Array.length states) /. (log 2.) in (* TODO: check this line *)
  let len = truncate @@ ceil flen in
  let breg = String.make len '0' in
  let istatebin = _val_to_binary initial in
  let istatepad = String.make (len - String.length istatebin) '0' in
  Printf.sprintf "%s=%s=%c%c"
  ++ breg
  ++ (istatepad ^ istatebin)
  ++ '0'
  ++ '0'

let output jsonfile =
  let db = ProgramData.of_jsonfile jsonfile in
  i'm_lazy_right_now := db.ProgramData.blank;
  Printf.printf "%s=%s="
  ++ _states_to_input db
  ++ _buffer_to_input db

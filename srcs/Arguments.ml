(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Arguments.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/26 14:15:45 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/19 16:08:35 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type modes = Exec of string * string * bool * bool
		   | Convert of string * string * bool

let _placeholderstr str =
  Printf.eprintf "placeholder \"%s\"\n%!" str;
  ()

let read () =
  let anon_str = [|None; None|] in
  let anon_count = ref 0 in
  let convert_ptr = ref false in
  let nooutput_ptr = ref false in
  let fileinput_ptr = ref false in
  let anon_fun str =
	match !anon_count with
	| 0 -> anon_str.(0) <- Some str; incr anon_count
	| 1 -> anon_str.(1) <- Some str; incr anon_count
	| _ -> raise @@ Arg.Bad "" in

  let usage_msg = "usage: ft_turing [-c] [-h] jsonfile input" in
  let speclist = [
	  ("jsonfile", Arg.String _placeholderstr
	   , "json description of the machine")
	; ("input", Arg.String _placeholderstr, "input of the machine")
	; ("-c", Arg.Set convert_ptr
	   , "convert a .json to a Virtual Turing Machine input")
	; ("-s", Arg.Set nooutput_ptr
	   , "disable step by step print")
	; ("-f", Arg.Set fileinput_ptr
	   , "treat input as a path to a file containing the input")
	; ("-h", Arg.Unit (fun _ -> raise @@ Arg.Bad "")
	   , "Display this list of options")
	] in

  Arg.parse speclist anon_fun usage_msg;
  match !convert_ptr, anon_str.(0), anon_str.(1) with
  | false, Some jsonfile, Some input ->
	 Exec (jsonfile, input, !nooutput_ptr, !fileinput_ptr)
  | true, Some jsonfile, Some input ->
	 Convert (jsonfile, input, !fileinput_ptr)
  | _, _, _ -> Arg.usage speclist usage_msg;
			   exit 1

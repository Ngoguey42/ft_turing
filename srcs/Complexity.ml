(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:11:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/01/30 19:38:20 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let maxstrlen = 10

module PD = ProgramData
module CA = Core.Core_array

let (++) = (@@)

let i = ref 0

let rec loop results db alpha str strlen =
  incr i;
  (* Printf.eprintf "\"%s\"\n%!" (Bytes.to_string str); *)
  let membership = Verifier.verify db str in
  (match membership with
   | Verifier.Member steps ->
	  let (prev, _) = CA.unsafe_get results strlen in
	  if steps > prev
	  then CA.unsafe_set results strlen (steps, str);
  (* Printf.eprintf "\"%s\" %d \n%!" str steps *)
	  ()
   | _ -> ()
  );
  match strlen < maxstrlen, membership with
  | true, Verifier.Member steps
  | true, Verifier.Not steps when steps >= strlen ->
	 CA.iter alpha ~f:(fun c ->
			   (* Bytes.set str strlen c; *)
			   loop results db alpha
					(str ^ (String.make 1 c))
					(strlen + 1));
	 (* Bytes.set str strlen db.PD.blank *)
  (* Printf.eprintf "Droping fail: %s\n%!" str; *)
  | _, _ -> ()


let alpha_filter db char =
  if char = db.PD.blank
  then None
  else Some char

let tot alphalen =
  let alphalen = float alphalen in
  let maxlenplus1 = float @@ maxstrlen + 1 in
  (1. -. (alphalen ** maxlenplus1)) /. (1. -. alphalen)

let compute db =
  let alpha = CA.filter_map db.PD.alphabet ~f:(alpha_filter db) in
  let results = CA.create ~len:(maxstrlen + 1) (~-1, "") in
  loop results db alpha "" 0;
  CA.iteri results ~f:(fun i (v, str) -> Printf.eprintf "%3d\t%3d \"%s\"\n%!" i v str);

  (* let rec fact i acc = match i with 0 -> acc | _ -> fact (i - 1) (acc * i) in *)

  Printf.eprintf "i = %d  / %f\n%!" !i
  @@ tot ++ Array.length alpha;
  ()

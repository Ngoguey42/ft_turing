(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard_tester.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 15:41:24 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/17 18:32:27 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module LGuard = LoopGuard.Make(struct
								type t = int
								let hash a = a
								let equal a b = a = b
								let tostring a = Printf.sprintf "%d" a;
							  end)

let tests = [
	1; 2; 3; 1; 2;
	0; 1;
	(* 0; 1; 42; *)
	0
  ]
(* let tests = [ *)
(* 	2; 1; *)
(* 	2; 1; 3; 42; *)
(* 	2; 1; 3; 42; *)
(* 	2] *)


let () =
  (* List.iter (fun v -> *)
  (* 	  Printf.eprintf "%d\n%!" v; *)
  (* 	  LGuard.update v *)
  (* 	) tests ; *)

  Printf.eprintf "*****************\n%!";
  Random.self_init ();
  let prev = ref 42 in
  let pprev = ref 42 in

  for i = 0 to 100000000 do
  	let v = Random.int 500 in

	if v <> !prev && v <> !pprev then (
	(* if v <> !prev then ( *)
	(* if true then ( *)
  	  (* Printf.eprintf "i(%d) state:%d\n%!" i v; *)
  	  LGuard.update v
	);
	pprev := !prev;
	prev := v;
  done;

  ()

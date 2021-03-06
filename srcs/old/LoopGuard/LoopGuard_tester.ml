(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LoopGuard_tester.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/12/13 15:41:24 by ngoguey           #+#    #+#             *)
(*   Updated: 2015/12/13 16:17:12 by ngoguey          ###   ########.fr       *)
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
	0; 1; 42;
	0; 1; 42;
	0
  ]
(* let tests = [ *)
(* 	2; 1; *)
(* 	2; 1; 3; 42; *)
(* 	2; 1; 3; 42; *)
(* 	2] *)


let () =
  List.iter (fun v ->
  	  Printf.eprintf "%d\n%!" v;
  	  LGuard.update v
  	) tests ;

  Printf.eprintf "*****************\n%!";
  Random.self_init ();
  for i = 0 to 10 do
  	let v = Random.int 5 in
  	Printf.eprintf "%d\n%!" v;
  	LGuard.update v;
  done;

  ()

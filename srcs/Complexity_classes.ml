(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity_classes.ml                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/02 18:22:09 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/02 19:12:55 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module CL = Core.Core_list

let genO1 (_, y) count =
  let onePercent = y *. 0.01 in
  CL.init count ~f:(fun i -> (float i, onePercent +. y))

let genOlogN (x, y) count =
  ()

let genON (x, y) count =
  let onePercent = y *. 0.01 in
  let dt = y /. x in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, onePercent +. i *. dt))

let genON2 (x, y) count =
  let onePercent = y *. 0.01 in
  let constant = y /. (x ** 2.) in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, onePercent +. i ** 2. *. constant))

(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity_classes.ml                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/02 18:22:09 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/02 19:59:08 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module CL = Core.Core_list

let genO1 (_, y) count =
  CL.init count ~f:(fun i -> (float i, y))

let genOlogN (x, y) count =
  let constant = y /. (log x) in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, log i *. constant))

let genON (x, y) count =
  let dt = y /. x in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, i *. dt))

let genON2 (x, y) count =
  let constant = y /. (x ** 2.) in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, i ** 2. *. constant))

let genON3 (x, y) count =
  let constant = y /. (x ** 3.) in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, i ** 3. *. constant))

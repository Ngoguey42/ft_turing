(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity_classes.ml                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/02 18:22:09 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/08 14:38:26 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module CL = Core.Core_list

(* Helpers *)
let make (x, y) count ~f =
  let constant = y /. (f x) in
  CL.init count ~f:(fun i -> let i = float i in
							 (i, f i *. constant))
let rec fact x i =
  match i with
  | 0 -> x
  | _ -> fact (x *. float i) (i - 1)

(* Trend Lines Funcs *)
let genO1 (_, y) count =
  CL.init count ~f:(fun i -> (float i, y))

let genOlogN point count =
  make point count ~f:(fun x -> log x)

let genON point count =
  make point count ~f:(fun x -> x)

let genONlogN point count =
  make point count ~f:(fun x -> x *. log x)

let genON2 point count =
  make point count ~f:(fun x -> x ** 2.)

let genO2N point count =
  make point count ~f:(fun x -> 2. ** x)

let genONfact point count =
  make point count ~f:(fun x -> fact 1. @@ truncate x)

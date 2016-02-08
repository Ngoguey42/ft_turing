(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity_classes.ml                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/02 18:22:09 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/08 16:35:32 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module CL = Core.Core_list

(* Trend Helpers *)
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


(* Linearization Helpers *)
let filter (x, y) =
  match classify_float x, classify_float y with
  | FP_infinite, _
  | FP_nan, _
  | _, FP_infinite
  | _, FP_nan
	-> None
  | _, _ -> Some (x, y)

(* Linearization Funcs *)
let linearNoOp res ref_point count =
  res

let linearOlogN res ref_point count =
  CL.filter_map res ~f:(fun (x, y) -> filter (log x, y))

let linearONlogN res ref_point count =
  CL.filter_map res ~f:(fun (x, y) -> filter (x *. log x, y))

let linearON2 res ref_point count =
  CL.filter_map res ~f:(fun (x, y) -> filter (log x, log y))

let linearO2N res ref_point count =
  CL.filter_map res ~f:(fun (x, y) -> filter (x, log y))

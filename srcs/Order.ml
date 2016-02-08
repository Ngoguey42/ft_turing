(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Order.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/08 11:26:31 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/08 16:43:33 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module GP = Gnuplot
module CL = Core.Core_list

type point = float * float

type t = { title : string
		 ; color : GP.Color.t
		 ; points : point list
		 ; lpoints : point list
		 ; correlation_coef : float
		 ; slope : float
		 ; mutable choice : bool
		 }

let calc_coef : point list -> float = fun lpoints ->
  match CL.hd lpoints with
  | None
	-> 0.
  | Some _
	-> 42.42

let calc_slope : point list -> float = fun lpoints ->
  42.42

let make :
	  string
	  -> GP.Color.t
	  -> point list
	  -> point
	  -> int
	  -> (point -> int -> point list)
	  -> (point list -> point -> int -> point list)
	  -> t = fun tit col res ref_point count make_points make_lpoints ->
  let lpoints = make_lpoints res ref_point count in
  { title = tit
  ; color = col
  ; points = make_points ref_point count
  ; lpoints
  ; correlation_coef = calc_coef lpoints
  ; slope = calc_slope lpoints
  ; choice = false
  }

let get_coef : t -> float = fun {correlation_coef} ->
  correlation_coef

let get_trend_line : t -> GP.Series.t = fun {title; color; points} ->
  GP.Series.lines_xy ~weight:1 ~color ~title points

let get_linearized_line : t -> point -> point -> GP.Series.t option =
  fun {title; color; lpoints} (bl_x, bl_y) (tr_x, tr_y) ->
  let xmin, xmax, ymin, ymax =
	CL.fold_left lpoints ~init:(infinity, 0., infinity, 0.)
				 ~f:(fun (xmin, xmax, ymin, ymax) (x, y) ->
				   (min xmin x
				   ,max xmax x
				   ,min ymin y
				   ,max ymax y)
				 )
  in
  let src_dx, src_dy = xmax -. xmin, ymax -. ymin in
  let dst_dx, dst_dy = tr_x -. bl_x, tr_y -. bl_y in
  Printf.eprintf "src_dx %f  src_dy %f\n%!" src_dx src_dy;
  Printf.eprintf "dst_dx %f  dst_dy %f\n%!" dst_dx dst_dy;
  let lpoints = CL.map lpoints ~f:(fun (x, y) ->
  						 ((x -. xmin) /. src_dx *. dst_dx +. bl_x
  						 ,(y -. ymin) /. src_dy *. dst_dy +. bl_y)
  					   )
  in
  match CL.hd lpoints with
  | None
	-> None
  | Some _
	-> Some (GP.Series.lines_xy lpoints ~weight:1 ~color
								~title:("results " ^ title ^ " log-log plot"))

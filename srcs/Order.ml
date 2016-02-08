(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Order.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/08 11:26:31 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/08 14:45:48 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module GP = Gnuplot

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
  42.42

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

let get_linearized_line : t -> point -> point -> GP.Series.t =
  fun {title; color; lpoints} bot_left top_right ->
  let lpoints = lpoints in
  (* TODO: process lpoints for display *)
  GP.Series.lines_xy ~weight:1 ~color ~title:(title ^ " linear") lpoints

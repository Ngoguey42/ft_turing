(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Order.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/08 11:26:31 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/08 12:03:16 by ngoguey          ###   ########.fr       *)
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



let make :
	  string
	  -> GP.Color.t
	  -> point list
	  -> point
	  -> int
	  -> (point -> int -> point list)
	  -> (point list -> point -> int -> point list)
	  -> t = fun tit col res ref_point count make_points make_lpoints ->
  { title = tit
  ; color = col
  ; points = []
  ; lpoints = []
  ; correlation_coef = 0.
  ; slope = 0.
  ; choice = false
  }

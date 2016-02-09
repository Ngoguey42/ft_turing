(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Order.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/02/08 11:26:31 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/09 14:02:46 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module GP = Gnuplot
module CL = Core.Core_list

type point = float * float

type t = { title : string
		 ; color : GP.Color.t
		 ; points : point list
		 ; lpoints : point list
		 ; ccoef : float
		 ; slope : float
		 ; mutable choice : bool
		 }

let calc_coef_slope : point list -> float * float = fun lpoints ->
  match CL.nth lpoints 1 with
  | None
	-> 0., 1.
  | Some _
	->
	 let count = float @@ CL.length lpoints in
	 let sum_x =
	   CL.fold_left lpoints ~init:0. ~f:(fun acc (x, _) -> acc +. x) in
	 let sum_y =
	   CL.fold_left lpoints ~init:0. ~f:(fun acc (_, y) -> acc +. y) in
	 let mean_x = sum_x /. count in
	 let mean_y = sum_y /. count in
	 let sum_dtmeanx_time_dtmeany =
	   CL.fold_left lpoints ~init:0.
					~f:(fun acc (x, y) -> acc +. (x -. mean_x) *. (y -. mean_y))
	 in
	 let sqrd_sum_dtmeanx =
	   CL.fold_left lpoints ~init:0.
					~f:(fun acc (x, _) -> acc +. (x -. mean_x) ** 2.) in
	 let slope = sum_dtmeanx_time_dtmeany /. sqrd_sum_dtmeanx in
	 let y0 = mean_y -. slope *. mean_x in
	 let reg_line = CL.map lpoints ~f:(fun (x, _) -> x, slope *. x +. y0) in
	 let sqrd_sum_dtmeany =
	   CL.fold_left lpoints ~init:0.
					~f:(fun acc (_, y) -> acc +. (y -. mean_y) ** 2.) in
	 let sqrd_sum_dtmeany_regln =
	   CL.fold_left reg_line ~init:0.
					~f:(fun acc (_, y) -> acc +. (y -. mean_y) ** 2.) in
	 let coef = sqrd_sum_dtmeany_regln /. sqrd_sum_dtmeany in
	 (* Printf.eprintf "mean_x %f\n%!" mean_x; *)
	 (* Printf.eprintf "mean_y %f\n%!" mean_y; *)
	 (* Printf.eprintf "%f points\n%!" count; *)
	 (* Printf.eprintf "sum_dtmeanx_time_dtmeany %f\n%!" sum_dtmeanx_time_dtmeany; *)
	 (* Printf.eprintf "sqrd_sum_dtmeanx %f\n%!" sqrd_sum_dtmeanx; *)
	 (* Printf.eprintf "sqrd_sum_dtmeany %f\n%!" sqrd_sum_dtmeany; *)
	 Printf.eprintf "\t%.2f * x + %.2f" slope y0;
	 Printf.eprintf "\tcoef: %f%!" coef;

	 coef, slope

let make :
	  string
	  -> GP.Color.t
	  -> point list
	  -> point
	  -> int
	  -> (point -> int -> point list)
	  -> (point list -> point -> int -> point list)
	  -> t = fun tit col res ref_point count make_points make_lpoints ->
  Printf.eprintf "%s%!" tit;
  let lpoints = make_lpoints res ref_point count in
  let ccoef, slope = calc_coef_slope lpoints in
  Printf.eprintf "\n%!";
  (* if tit = "O(n^2)" then ( *)
  (* CL.iter lpoints ~f:(fun (x, y) -> *)
  (* 			Printf.eprintf "%f\t%f\n%!" x y; *)

  (* 		  )); *)
  { title = tit
  ; color = col
  ; points = make_points ref_point count
  ; lpoints
  ; ccoef
  ; slope
  ; choice = false
  }

let get_coef : t -> float = fun {ccoef} ->
  ccoef

let get_trend_line : t -> GP.Series.t = fun {title; color; points} ->
  GP.Series.lines_xy ~weight:1 ~color ~title points

let build_title : t -> string = fun {title; ccoef; slope; choice} ->
  let hd = match choice with | true -> "->" | false -> "" in
  match title with
  | "O(n^2)" ->
	 Printf.sprintf "%s r^2(%.4f) results O(n**%.4f) log-log plot" hd ccoef slope
  | "O(2^n)" ->
	 Printf.sprintf "%s r^2(%.4f) results O(%.4f**n) log-log plot" hd ccoef (exp slope)
  | _ ->
	 Printf.sprintf "%s r^2(%.4f) results %s log-log plot" hd ccoef title

let get_linearized_line : t -> point -> point -> GP.Series.t option =
  fun ({title; color; lpoints; choice} as ord) (bl_x, bl_y) (tr_x, tr_y) ->
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
  let lpoints = CL.map lpoints ~f:(fun (x, y) ->
  						 ((x -. xmin) /. src_dx *. dst_dx +. bl_x
  						 ,(y -. ymin) /. src_dy *. dst_dy +. bl_y)
  					   )
  in
  match CL.hd lpoints with
  | None
	-> None
  | Some _
	-> let ttl = build_title ord in
	   Some (GP.Series.lines_xy lpoints ~weight:1 ~color ~title:ttl)

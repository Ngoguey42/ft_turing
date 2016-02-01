(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:11:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/01 17:57:06 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let maxstrlen = 500

module PD = ProgramData
module CA = Core.Core_array
module GP = Gnuplot

let (++) = (@@)

let i = ref 0

let rec loop results db alpha str strlen =
  incr i;
  (* Printf.eprintf "\"%s\"\n%!" (Bytes.to_string str); *)
  let membership = Verifier.verify db str in
  (match membership with
   | Verifier.Member steps ->
	  let (prev, _) = CA.unsafe_get results strlen in
	  if steps > prev
	  then CA.unsafe_set results strlen (steps, str);
	  (* Printf.eprintf "\"%s\" %d \n%!" str steps *)
	  ()
   | _ -> ()
  );
  match strlen < maxstrlen, membership with
  | true, Verifier.Member steps
  | true, Verifier.Not steps when steps >= strlen ->
	 CA.iter alpha ~f:(fun c ->
			   (* Bytes.set str strlen c; *)
			   loop results db alpha
					(str ^ (String.make 1 c))
					(strlen + 1));
  (* Bytes.set str strlen db.PD.blank *)
  (* Printf.eprintf "Droping fail: %s\n%!" str; *)
  | _, _ -> ()


let alpha_filter db char =
  if char = db.PD.blank
  then None
  else Some char

let tot alphalen =
  if alphalen = 1
  then float @@ maxstrlen + 1
  else (
	let alphalen = float alphalen in
	let maxlenplus1 = float @@ maxstrlen + 1 in
	(1. -. (alphalen ** maxlenplus1)) /. (1. -. alphalen)
  )

let canvasW = 1000
let canvasH = 800
let canvasInsetPercentX = 0.1
let canvasInsetPercentY = canvasInsetPercentX
						  *. (float canvasW) /. (float canvasH)
let canvasInsetFactorX = 1. /. (1. -. canvasInsetPercentX)
let canvasInsetFactorY = 1. /. (1. -. canvasInsetPercentY)

let gnuPlotConf db maxX maxY =
  let output = GP.Output.create
				 (`Canvas ((db.PD.name ^ ".html"), canvasW, canvasH)) in
  let rangeMaxX = maxX *. canvasInsetFactorX in
  let rangeMaxY = maxY *. canvasInsetFactorY in
  let range = GP.Range.XY (0., rangeMaxX, 0., rangeMaxY) in
  let pointsW = 2 in
  output, range, pointsW

let pointsLstOfTupArray tupArr =
  CA.foldi
	~init:[]
	~f:(fun i lst (count, _) ->
	  if count < 0
	  then lst
	  else(float i, float count)::lst
	)
	tupArr

let toGnuPlot db results =
  let maxY, _ = CA.last results in
  let maxX = Array.length results - 1 in
  let output, range, pointsW = gnuPlotConf db ++ float maxX ++ float maxY in
  let pointsLst = pointsLstOfTupArray results in
  let pointsGp = GP.Series.points_xy ~weight:pointsW ~color:`Red pointsLst in
  let gp = GP.Gp.create () in
  GP.Gp.plot
	gp
	pointsGp
	~output:output
	~use_grid:true
	~range:range;
  GP.Gp.close gp;
  ()


let compute db =
  let alpha = CA.filter_map db.PD.alphabet ~f:(alpha_filter db) in
  let results = CA.create ~len:(maxstrlen + 1) (~-1, "") in
  loop results db alpha "" 0;
  CA.iteri results ~f:(fun i (v, str) -> Printf.eprintf "%3d\t%3d \"%s\"\n%!" i v str);


  (* let rec fact i acc = match i with 0 -> acc | _ -> fact (i - 1) (acc * i) in *)

  Printf.eprintf "i = %d  / %f\n%!" !i
  @@ tot ++ Array.length alpha;
  toGnuPlot db results;
  ()

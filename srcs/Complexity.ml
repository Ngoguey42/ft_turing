(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:11:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/01 20:44:15 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module PD = ProgramData
module CA = Core.Core_array
module GP = Gnuplot

let maxstrlen = 15
let maxtime = 1.

let canvasW = 2300
let canvasH = 1200
let canvasInsetPercentX = 0.1
let canvasInsetPercentY = canvasInsetPercentX
						  *. (float canvasW) /. (float canvasH)
let canvasInsetFactorX = 1. /. (1. -. canvasInsetPercentX)
let canvasInsetFactorY = 1. /. (1. -. canvasInsetPercentY)

let (++) = (@@)

let i = ref 0



let rec loop results db alpha str strlen =
  incr i;
  let membership = Verifier.verify db str in
  (match membership with
   | Verifier.Member steps ->
	  let (prev, _) = CA.unsafe_get results strlen in
	  if steps > prev
	  then CA.unsafe_set results strlen (steps, str);
	  ()
   | _ -> ()
  );
  match strlen < maxstrlen, membership with
  | true, Verifier.Member steps
  | true, Verifier.Not steps when steps >= strlen ->
	 CA.iter alpha ~f:(fun c ->
			   loop results db alpha
					(str ^ (String.make 1 c))
					(strlen + 1));
  | _, _ -> ()
(* ) *)

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

let gnuPlotConf db maxX maxY =
  let output = GP.Output.create
				 (`Canvas ((db.PD.name ^ ".html"), canvasW, canvasH)) in
  let rangeMaxX = maxX *. canvasInsetFactorX in
  let rangeMaxY = maxY *. canvasInsetFactorY in
  let range = GP.Range.XY (0., rangeMaxX, 0., rangeMaxY) in
  let pointsW = 1 in
  output, range, pointsW

let pointsLstOfTupArray tupArr =
  CA.foldi
	tupArr
	~init:[]
	~f:(fun i lst (count, _) ->
	  if count < 0
	  then lst
	  else (float i, float count)::lst
	)

let toGnuPlot db results maxX maxY =
  (* let maxY, _ = CA.last results in *)
  (* let maxX = Array.length results - 1 in *)
  let output, range, pointsW = gnuPlotConf db ++ float maxX ++ float maxY in
  let pointsLst = pointsLstOfTupArray results in
  let linesGp = GP.Series.lines_xy ~weight:2 ~color:`Red pointsLst in
  let pointsGp = GP.Series.points_xy ~weight:2 ~color:`Red pointsLst in

  let pointsLst2 = List.map (fun (x, y) ->
  					   (* Printf.eprintf "%f, %f ->   %f, %f\n%!" *)
  					   (* 				  x y *)
  					   (* 				  x (log y *. 10000.) *)
  					   (* ; *)
  					   (x, y *. 2.)
  					 (* (x, (log y) *. (float maxY) /. (float maxX)) *)
  					 ) pointsLst in
  let linesGp2 =  GP.Series.lines_xy ~weight:1 ~color:`Red pointsLst2 in

  let gp = GP.Gp.create () in
  GP.Gp.plot_many gp [
					pointsGp; linesGp;

					linesGp2
				  ]
				  ~output:output
				  ~use_grid:true
				  ~range:range;
  GP.Gp.close gp;
  ()

let compute db =
  let alpha = CA.filter_map db.PD.alphabet ~f:(alpha_filter db) in
  let results = CA.create ~len:(maxstrlen + 1) (~-1, "") in
  loop results db alpha "" 0;
  (* val foldi : 'a t -> init:'b -> f:(int -> 'b -> 'a -> 'b) -> 'b *)
  let lasti, maxy =
	CA.foldi
	  results
	  ~init:(0, 0)
	  ~f:(fun i ((maxi, maxy) as tup) (v, str) ->
		if v > 0 then (
		  Printf.eprintf "%3d\t%3d \"%s\"\n%!" i v str;
		  (i, v)
		)
		else tup
	  )
  in
  Printf.eprintf "i = %d  / %f\n%!" !i
  @@ tot ++ (lasti + 1);
  (* @@ tot ++ Array.length alpha; *)
  toGnuPlot db results lasti maxy;
  ()

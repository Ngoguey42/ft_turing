(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:11:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/03 14:46:58 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module PD = ProgramData
module CA = Core.Core_array
module GP = Gnuplot
module TTK = StringListTickTock
module Class = Complexity_classes

let maxstrlen = 258
let maxtime = 60.

let canvasW = 2300
let canvasH = 1200
let canvasInsetPercentX = 0.1
let canvasInsetPercentY = canvasInsetPercentX
						  *. (float canvasW) /. (float canvasH)
let canvasInsetFactorX = 1. /. (1. -. canvasInsetPercentX)
let canvasInsetFactorY = 1. /. (1. -. canvasInsetPercentY)

let refPointPercent = 0.65

let (++) = (@@)

let i = ref 0

let loop (results, db, alpha, ttk) =
  let str = TTK.pop ttk in
  let strlen = TTK.phase ttk in
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
  | true, Verifier.Not steps when steps > strlen ->
	 CA.iter alpha ~f:(fun c -> TTK.add ttk (str ^ (String.make 1 c)))
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

let gnuPlotConf db maxX maxY =
  let output = GP.Output.create
				 (`Canvas ((db.PD.name ^ ".html"), canvasW, canvasH)) in
  let rangeMaxX = maxX *. canvasInsetFactorX in
  let rangeMaxY = maxY *. canvasInsetFactorY in
  let range = GP.Range.XY (0., rangeMaxX, 0., rangeMaxY) in
  output, range

let pointsLstOfTupArray tupArr =
  CA.foldi
	tupArr
	~init:[]
	~f:(fun i lst (count, _) ->
	  if count < 0
	  then lst
	  else (float i, float count)::lst
	)


(* let makeRefPoint results maxX = *)

let makeTrendLine refPoint count fn title color =
  GP.Series.lines_xy ~weight:1 ~color ~title
  @@ fn refPoint count


let makeTrendLines refPoint count =
  Printf.eprintf "count: %d\n%!" count;
  [makeTrendLine refPoint count Class.genO1 "O(1)" `Blue
  ;makeTrendLine refPoint count Class.genOlogN "O(logn)" @@ `Rgb (85, 43, 27)
  ;makeTrendLine refPoint count Class.genON "O(n)" `Green
  ;makeTrendLine refPoint count Class.genONlogN "O(nlogn)" @@ `Rgb (187, 0, 255)
  ;makeTrendLine refPoint count Class.genON2 "O(n^2)" @@ `Rgb (96, 151, 159)
  ;makeTrendLine refPoint count Class.genON3 "O(n^3)" @@ `Rgb (81, 125, 132)
  ;makeTrendLine refPoint count Class.genO2N "O(2^n)" @@ `Yellow
  ;makeTrendLine refPoint count Class.genO3N "O(3^n)" @@ `Yellow
  ;makeTrendLine refPoint count Class.genONfact "O(n!)" @@ `Blue
  ]

let findRefPoint results maxX =
  let y (y, _) =
	y
  in
  let rec findX center dt sign =
	match center + sign * dt with
	| x when x > maxX || x < 0 -> failwith "Error"
	| x when y results.(x) >= 0 -> x
	| _ when sign = 1 -> findX center dt ~-1
	| _ -> findX center (dt + 1) 1
  in
  let center = truncate ++ floor (refPointPercent *. float maxX) in
  let refPointX = findX center 0 1 in
  let refPointY, _ = CA.unsafe_get results refPointX in
  (float refPointX, float refPointY)

let toGnuPlot db results maxX maxY =
  let output, range = gnuPlotConf db ++ float maxX ++ float maxY in
  let pointsLst = pointsLstOfTupArray results in
  let linesGp = GP.Series.lines_xy ~weight:2 ~color:`Red pointsLst in
  let pointsGp = GP.Series.points_xy ~weight:2 ~color:`Red pointsLst in
  let refPoint = findRefPoint results maxX in

  let gp = GP.Gp.create () in
  GP.Gp.plot_many
	gp (pointsGp::linesGp::makeTrendLines refPoint (maxX + 1))
	~output:output
	~use_grid:true
	~range:range
	~labels:(GP.Labels.create ~x:"strlen" ~y:"steps" ())
  ;
  GP.Gp.close gp;
  ()

let compute db =
  let alpha = CA.filter_map db.PD.alphabet ~f:(alpha_filter db) in
  let results = CA.create ~len:(maxstrlen + 1) (~-1, "") in
  let ttk = TTK.create "" in
  let timeout = Unix.gettimeofday () +. maxtime in

  Printf.printf "Computing graph: maxtime(%fs) maxstrlen(%d)\n%!"
				maxtime maxstrlen;
  while Unix.gettimeofday () < timeout && not (TTK.empty ttk) do
	loop (results, db, alpha, ttk);
	incr i
  done;
  if not ++ TTK.empty ttk then (
	Printf.eprintf "Dropping results for stren=%d\n%!"
	@@ TTK.phase ttk;
	results.(TTK.phase ttk) <- (~-1, "")
  );
  let lasti, maxy =
	CA.foldi
	  results
	  ~init:(0, 0)
	  ~f:(fun i ((maxi, maxy) as tup) (v, str) ->
		if v > 0 then (
		  (* Printf.eprintf "%3d\t%3d \"%s\"\n%!" i v str; *)
		  (i, v)
		)
		else tup
	  )
  in
  Printf.eprintf "i = %d  / %f\n%!" !i
  @@ tot ++ (lasti + 1);
  toGnuPlot db results lasti maxy;
  ()

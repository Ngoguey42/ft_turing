(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:11:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/08 15:40:00 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module PD = ProgramData
module CA = Core.Core_array
module CL = Core.Core_list
module GP = Gnuplot
module TTK = StringListTickTock
module Class = Complexity_classes

let maxstrlen = 258
let maxtime = 2.

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


(* let makeTrendLine refPoint count fn title color = *)
(*   GP.Series.lines_xy ~weight:1 ~color ~title *)
(*   @@ fn refPoint count *)


(* let makeTrendLines refPoint count = *)
(*   Printf.eprintf "count: %d\n%!" count; *)
(*   [makeTrendLine refPoint count Class.genO1 "O(1)" `Blue *)
(*   ;makeTrendLine refPoint count Class.genOlogN "O(logn)" @@ `Rgb (85, 43, 27) *)
(*   ;makeTrendLine refPoint count Class.genON "O(n)" `Green *)
(*   ;makeTrendLine refPoint count Class.genONlogN "O(nlogn)" @@ `Rgb (187, 0, 255) *)
(*   ;makeTrendLine refPoint count Class.genON2 "O(n^2)" @@ `Rgb (96, 151, 159) *)
(*   ;makeTrendLine refPoint count Class.genO2N "O(2^n)" @@ `Yellow *)
(*   ;makeTrendLine refPoint count Class.genONfact "O(n!)" @@ `Blue *)
(*   ] *)


let ph _ _ _ = []

let gen_orders results refPoint count =
  [
  (* 	Order.make "O(1)" `Blue results refPoint count Class.genO1 ph *)
  (* ; Order.make "O(logn)" (`Rgb (85, 43, 27)) results refPoint count Class.genOlogN ph *)
  (* ; Order.make "O(n)" `Green results refPoint count Class.genON ph *)
  (* ; Order.make "O(nlogn)" (`Rgb (187, 0, 255)) results refPoint count Class.genONlogN ph *)
	Order.make "O(n^2)" (`Rgb (96, 151, 159)) results refPoint count Class.genON2 Class.linearON2
  ; Order.make "O(2^n)" `Yellow results refPoint count Class.genO2N Class.linearO2N
  (* ; Order.make "O(n!)" `Blue results refPoint count Class.genONfact ph *)
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
  let output, range = gnuPlotConf db (float maxX) (float maxY) in
  let pointsLst = pointsLstOfTupArray results in
  let linesGp = GP.Series.lines_xy ~weight:2 ~color:`Red pointsLst in
  let pointsGp = GP.Series.points_xy ~weight:2 ~color:`Red pointsLst in
  let refPoint = findRefPoint results maxX in
  let orders = gen_orders pointsLst refPoint (maxX + 1) in
  let orders =
	CL.sort
	  ~cmp:(fun {Order.correlation_coef = a} {Order.correlation_coef = b} ->
		truncate ((a -. b) *. 1000.))
	  orders
  in
  (match orders with
  (* | hdo1::hdon::_ when hdo1.Order.title = "O(1)" *)
  (* 	-> assert(hdon.Order.title = "O(N)"); *)
  (* 	   if hdo1.Order.slope > 0.95 && hdo1.Order.slope < 1.05 *)
  (* 	   then hdo1.Order.choice <- true *)
  (* 	   else hdon.Order.choice <- true *)
  (* | hdon::hdo1::_ when hdo1.Order.title = "O(1)" *)
  (* 	-> assert(hdon.Order.title = "O(N)"); *)
  (* 	   if hdo1.Order.slope > 0.95 && hdo1.Order.slope < 1.05 *)
  (* 	   then hdo1.Order.choice <- true *)
  (* 	   else hdon.Order.choice <- true *)
  | hd1::_
	-> hd1.Order.choice <- true
  | []
	-> failwith "noway"
  );
  let trends = CL.map orders ~f:(fun ord -> Order.get_trend_line ord) in
  let l_botleft = (0., float maxY /. 2.) in
  let l_topright = (float maxX /. 2., float maxY) in
  let linearized = CL.map orders ~f:(fun ord -> Order.get_linearized_line
												  ord l_botleft l_topright) in

  let gp = GP.Gp.create () in
  GP.Gp.plot_many
	gp (pointsGp::linesGp::(trends @ linearized))
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

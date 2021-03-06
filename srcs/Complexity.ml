(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Complexity.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/01/30 16:11:00 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/02/09 14:02:31 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module PD = ProgramData
module CA = Core.Core_array
module CL = Core.Core_list
module GP = Gnuplot
module TTK = StringListTickTock
module Class = Complexity_classes

let maxstrlen =  10000
let maxtime = 60.

let canvasW = 2300
let canvasH = 1200
let canvasInsetPercentX = 0.07
let canvasInsetPercentY = canvasInsetPercentX
						  *. (float canvasW) /. (float canvasH)
let canvasInsetFactorX = 1. /. (1. -. canvasInsetPercentX)
let canvasInsetFactorY = 1. /. (1. -. canvasInsetPercentY)

let refPointPercent = 0.65
let subGraphSize = 0.4


let (++) = (@@)

(* GNU-PLOT AND COMPLEXITY CALCULATION *)

let gen_orders results refPoint count =
  let ph _ _ _ = [] in
  [ Order.make "O(1)" `Blue results refPoint count
			   Class.genO1 Class.linearNoOp
  ; Order.make "O(logn)" (`Rgb (85, 43, 27)) results refPoint count
			   Class.genOlogN Class.linearOlogN
  ; Order.make "O(n)" `Green results refPoint count
			   Class.genON Class.linearNoOp
  ; Order.make "O(nlogn)" (`Rgb (187, 0, 255)) results refPoint count
			   Class.genONlogN Class.linearONlogN
  ;	Order.make "O(n^2)" (`Rgb (96, 151, 159)) results refPoint count
			   Class.genON2 Class.linearON2
  ; Order.make "O(2^n)" `Yellow results refPoint count
			   Class.genO2N Class.linearO2N
  ; Order.make "O(n!)" `Blue results refPoint count
			   Class.genONfact ph
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

let make_subgraph_box l_botleft l_topright l_botright l_topleft =
  GP.Series.lines_xy ~weight:4 ~color:`Black
					 [l_botleft; l_botright; l_topright; l_topleft; l_botleft]

let calc_subgraph_bounds maxX maxY =
  let bot = float maxY *. (1. -. subGraphSize) *. canvasInsetFactorY in
  let top = float maxY *. canvasInsetFactorY in
  let right = float maxX *. subGraphSize *. canvasInsetFactorX in
  let left = 0. *. canvasInsetFactorX in
  (left, bot), (right, top), (right, bot), (left, top)

let process_title db l =
  Printf.sprintf "%s (%d points)"
  ++ Core.Core_string.map db.PD.name ~f:(fun c -> match c with
												  | '_' -> ' '
												  | '^' -> ' '
												  | _ -> c)
  ++ List.length l

let pointsLstOfTupArray tupArr =
  CA.foldi
	tupArr
	~init:[]
	~f:(fun i lst (count, _) ->
	  if count < 0
	  then lst
	  else (float i, float count)::lst
	)

let gnuPlotConf db maxX maxY =
  let output = GP.Output.create
				 (`Canvas ((db.PD.name ^ ".html"), canvasW, canvasH)) in
  let rangeMaxX = maxX *. canvasInsetFactorX in
  let rangeMaxY = maxY *. canvasInsetFactorY in
  let range = GP.Range.XY (0., rangeMaxX, 0., rangeMaxY) in
  output, range

let tag_best_rsquared orders =
  match orders with
  | hd1::_ -> hd1.Order.choice <- true
  | [] -> failwith "noway"

let sort_orders orders =
  CL.sort orders
		  ~cmp:(fun {Order.ccoef = ca; Order.slope = sa;  Order.title = ta}
					{Order.ccoef = cb; Order.slope = sb;  Order.title = tb} ->
			match ta, tb with
			| "O(1)", _ when sa < 0.01 -> -1
			| _, "O(1)" when sb < 0.01 -> 1
			| "O(n)", "O(1)" when ca > 0.95 -> -1
			| "O(1)", "O(n)" when cb > 0.95 -> 1
			| _, _ when (cb -. ca) > 0. -> 1
			| _, _ -> -1
		  )


let toGnuPlot db results maxX maxY =
  let output, range = gnuPlotConf db (float maxX) (float maxY) in
  let pointsLst = pointsLstOfTupArray results in
  let linesGp = GP.Series.lines_xy
				  ~weight:3 ~title:(process_title db pointsLst)
				  ~color:`Red pointsLst in
  let pointsGp = GP.Series.points_xy ~weight:1 ~color:`Red pointsLst in
  let refPoint = findRefPoint results maxX in
  let orders = gen_orders pointsLst refPoint (maxX + 1) in
  let orders = sort_orders orders in
  (* in *)
  tag_best_rsquared orders;
  let trends = CL.map orders ~f:(fun ord -> Order.get_trend_line ord) in
  let l_botlef, l_toprig, l_botrig, l_toplef = calc_subgraph_bounds maxX maxY in
  let linearized = CL.filter_map orders
								 ~f:(fun ord -> Order.get_linearized_line
												  ord l_botlef l_toprig) in
  let subgraph_box = make_subgraph_box l_botlef l_toprig l_botrig l_toplef in

  let gp = GP.Gp.create () in
  GP.Gp.plot_many
	gp (pointsGp::linesGp::subgraph_box::(trends @ linearized))
	~output:output
	~use_grid:true
	~range:range
	~labels:(GP.Labels.create ~x:"strlen" ~y:"steps" ())
  ;
	GP.Gp.close gp;
  ()

(* TURING MACHINE ENUMERATOR *)

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
	-> CA.iter alpha ~f:(fun c -> TTK.add ttk (str ^ (String.make 1 c)))
  | true, Verifier.Not steps when steps > strlen
	-> CA.iter alpha ~f:(fun c -> TTK.add ttk (str ^ (String.make 1 c)))
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

(* FILE ENTRY POINT *)

let compute db =
  let alpha = CA.filter_map db.PD.alphabet ~f:(alpha_filter db) in
  let results = CA.create ~len:(maxstrlen + 1) (~-1, "") in
  let ttk = TTK.create "" in
  let timeout = Unix.gettimeofday () +. maxtime in
  let i = ref 0 in

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
	CA.foldi results ~init:(0, 0)
			 ~f:(fun i ((maxi, maxy) as tup) (v, str) ->
			   if v > 0
			   then (
				 (* Printf.eprintf "%3d \"%s\"\n%!" v str; *)
				 (i, v)
			   )
			   else tup)
  in
  Printf.eprintf "i = %d  / %f\n%!" !i
  @@ tot ++ (lasti + 1);
  toGnuPlot db results lasti maxy;
  ()

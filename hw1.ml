(*this checks if each element of a is an element of b
*uses List.mem
 *)
let rec subset a b =match a with 
  |[]-> true
  |h::t -> List.mem h b && subset t b;;

(* Two sets are equal if they are subsets of each other.
* a is a subset of b and b is a subset of a.
*)
let rec equal_sets a b = subset a b && subset b a;;

(*
* List.sort_uniq removes duplicates and sorts the list
*)
let set_union a b = List.sort_uniq compare (List.append a b);;
(*
* 
*)
let rec set_intersection a b= if b=[] then [] else
				 match a with
				|[]->[] 
				| h::t -> if List.mem h b then List.append [h] (set_intersection t b)
						else set_intersection t b;;
(*
*
*)
let rec set_diff a b = if b=[] then a else
			match a with
			|[]->[]
			|h::t -> if List.mem h b then (set_diff t b) else
				List.append [h] (set_diff t b);;

(*
* by the definition of fixed point
*)
let rec computed_fixed_point eq f x= if eq (f x) x then x else computed_fixed_point eq f (f x);;

(*
*
*)
let rec computed_periodic_point eq f p x = match p with 
						| 0->x
						| 1-> (computed_fixed_point eq f x)
						| _-> if eq (apply_p_times eq f p x) x then x else computed_periodic_point eq f p (f x);;


let rec apply_p_times eq f p x= if p<>0 then (apply_p_times eq f (p-1) (f x)) else x;;

(*
*
*
*)





(*
* Filter blind alleys ( Nonterminal , [ Nonterminal, [T x; N y;...]; 
* 					Nonterminal, [T x; N k;...])
* start_exp,rhs is a rule
*
*)


(*
* Takes a rule and break it down to the subrules and checks if each subrule terminates
*)

let rec bool_terminates rule ruleset originalrule= 
if ruleset=[]||(match originalrule with |(_,[T "Not_Found"])->true|_->false) then false 
					else match rule with 
					|(hrule,trule) -> match trule with 
						|[]-> true
						|h::t -> match h with 
						|T _ -> true&&if t=[] then true else (bool_terminates (hrule,t) ruleset originalrule)
						|N nt -> let orule=(nt,try List.assoc nt (set_diff ruleset [originalrule]) with Not_found->[T "Not_Found"]) in bool_terminates orule (set_diff ruleset [originalrule]) orule && (bool_terminates (hrule,t) ruleset originalrule) ;;


let rec loopruleset ruleset unchangedruleset= match ruleset with
				|[]->[]
				|h::t -> if (bool_terminates h ruleset h)||(bool_terminates h unchangedruleset h) then [h]@(loopruleset t unchangedruleset) else (loopruleset t unchangedruleset);;



let filter_blind_alleys g = match g with 
				| (start_exp, ruleset)-> (start_exp, (loopruleset ruleset ruleset));;

(*
*
*
*
*
*)

(*
let rec bool_terminates rule ruleset originalrule= if ruleset=[]||match originalrule with |(_,[])->true|_->false then false else match rule with 
					|(hrule,trule) -> match trule with 
						|[]-> true
						|h::t -> match h with 
						|T _ -> true&&if t=[] then true else (bool_terminates (hrule,t) ruleset originalrule)
						|N nt -> let orule=(nt,try List.assoc nt (set_diff ruleset [originalrule]) with Not_found->[]) in bool_terminates orule (set_diff ruleset [originalrule]) orule && (bool_terminates (hrule,t) ruleset originalrule) ;;

(*
this works above
*)




let ruleset=
[Expr, [N Num]; Expr, [N Num; N Binop; T "0"]; Expr, [N Binop]; Binop, [T "+"]; Num, [N Num]];;
let rule=Expr, [N Num];;

let ruleset =[Expr,[T "0"; T "1";]; Expr, [T ")"]];;
let rule =Expr, [T "0"; T "1";];;
(*
888888888888888888888888888888888888888888888888

*)

let rec remove_non_terminals ruleset newruleset= match ruleset with 
						|h::t ->


let rhs= try List.assoc startexp ruleset with Not_found->[] in
			let rule=(startexp,rhs) in
			match rhs with |[]-> newruleset
				       |_ ->  
			if bool_terminates rule (set_diff ruleset [rule]) then remove_non_terminals startexp (set_diff ruleset [rule]) newruleset
			else  (remove_non_terminals startexp (set_diff ruleset [rule]) (set_union [rule] newruleset));;



(*
888888888888888888888888888888888888888888888888
*)




let bool_terminates rule ruleset = match rule with
					| (_,rhs) -> match rhs with |h::t -> termination_checker h ruleset

let termination_checker singlerule ruleset = match singlerule with 
						| T _ -> true  
						| N nt-> let rhs=try List.assoc nt ruleset in 
							let rule = [(nt,rhs)] in
						match rhs with |[]->false
							|h::t -> termination_checker h set_diff ruleset rule
				

let bool_terminates rule ruleset = match rule with
					| (_,rhs) ->  termination_checker rhs ruleset


let rec termination_checker rhs ruleset = match rhs with
						|[]->
						|h::t -> match h with 
						| T _ -> true && termination_checker t ruleset  
						| N nt-> let x=try List.assoc nt ruleset with Not_found-> [] in 
							let rule = [(nt,x)] in
						match x with |[]->false
							|h::t -> termination_checker h set_diff ruleset rule
				






		

let bool_terminates_checker startexp ruleset =if ruleset=[] then false else 
						let rhs=List.assoc startexp ruleset in
						let rule=(startexp,rhs) in bool_terminates rule ruleset;;



let rama ruleset newruleset = match ruleset with
				|[]->newruleset 
				|h::t -> match h with (a,b)->
					|
*)















let subset_test0 = subset [1] [7;8;9] = false;;

let equal_sets_test0 = equal_sets [1;3;1;3;2;3] [3;1;3;2];;

let set_union_test0 = equal_sets (set_union [1] [2;3]) [1;2;3];;

let set_intersection_test0 =equal_sets (set_intersection [4;5;6] [1;2;3]) [];;

let set_diff_test0 = equal_sets (set_diff [3;4] [1;4;3;1]) [];;

let computed_fixed_point_test0 =
  computed_fixed_point (=) (fun x -> x / 100) 10000000 = 0;;


let computed_periodic_point_test0 =
  computed_periodic_point (=) (fun x -> x / 100) 2 (-1) = 0;;




type grammar_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num

let grammartest0=[Expr, [N Num];
       Expr, [N Lvalue];
       Expr, [N Expr; N Lvalue];
       Expr, [N Lvalue; N Expr];
       Expr, [N Expr; N Binop; N Expr];
       Lvalue, [T"#"; N Expr];
       Lvalue, [N Expr; N Lvalue];
       Lvalue, [N Incrop; N Lvalue];
       Lvalue, [N Lvalue; N Incrop];
       Incrop, [T"++"]; Incrop, [T"--"];
       Binop, [T"+"]; Binop, [T"-"];
       Num, [T"0"]; Num, [T"1"]; Num, [T"2"]; Num, [T"3"]; Num, [T"4"];
       Num, [T"5"]; Num, [T"6"]; Num, [T"7"]; Num, [T"8"]; Num, [T"9"]];;

let grammar_test0 =
  filter_blind_alleys (Expr, grammartest0) = (Expr, grammartest0);;

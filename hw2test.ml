(*TEST 1*)
let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]];;
let awksub_gram1= (Expr,awksub_rules);;

let awksub_gram2= convert_grammar awksub_gram1;;

let test_1= (parse_prefix awksub_gram2 accept_all ["("; "5";")"]= Some ([(Expr, [T "("; N Expr; T ")"]); (Expr, [N Num]); (Num, [T "5"])], []));;


(*TEST 2*)
type test2_nonterminals = | CS131 | CS33 | CS35L | CS111;;

let test2_rules = [
CS33, [T "I"; N CS35L; N CS33] ;
CS33, [T "Prof."; N CS131];
CS35L, [N CS111];
CS111, [T "like"];
CS111, [T "do not like"];
CS131, [T "Eggert's"; T "classes"];
];;

let test2_gram = convert_grammar (CS33, test2_rules);;

let test_2= parse_prefix test2_gram accept_all ["I";"like";"Prof.";"Eggert's";"classes"]=  Some
   ([(CS33, [T "I"; N CS35L; N CS33]); (CS35L, [N CS111]);
     (CS111, [T "like"]); (CS33, [T "Prof."; N CS131]);
     (CS131, [T "Eggert's"; T "classes"])],
    []);;





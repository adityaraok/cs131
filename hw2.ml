(*
* converts grammar 1 to grammar 2
*)


(*
* set_diff function from hw1
*)
let rec set_diff a b = if b=[] then a else
			match a with
			|[]->[]
			|h::t -> if List.mem h b then (set_diff t b) else
				List.append [h] (set_diff t b);;

(*
* Returns the list of distinct (non-repeating) non terminals 
*)
let rec list_of_nonterminals ntList distinctNtsList= match ntList with | [] -> distinctNtsList
						      | h::t -> if List.mem h distinctNtsList then (list_of_nonterminals t distinctNtsList) else list_of_nonterminals t (List.append distinctNtsList [h]);;

(*
* this function extracts all the rhs associated with a given nonterminal and returns it.
* Essentially this is the function in the rhs of grammar 2 representation.
*)
let rec extract_rhs nt ruleSet alternateList= let rule=try (List.assoc nt ruleSet) with Not_found->[] in
			match rule with
			| [] ->alternateList
			| _-> extract_rhs nt (set_diff ruleSet [(nt,rule)]) (List.append alternateList [rule]) ;;

(*
* Starting point for the conversion of gram 1 to gram 2.
*
*)
let convert_grammar gram = match gram with |(a,b) -> let (lhs, _)=List.split b in
						format_for_grammar_two a (list_of_nonterminals lhs []) b;;

(*
* this function just maps the non terminal to its corresponding function (which in turn returns all the rhs associated with it. this 
* function is extract_rhs in my implementation)
*
*)
let rec format_for_grammar_two startExp distinctNtList ruleSet  =  match distinctNtList with
						|h::t -> (startExp, function h-> extract_rhs h ruleSet []);;

(*
*
*  DERIVATION- LEFT ASSOCIATED.
*
*)


(*
*  I have written three mutually recursive functions to implement the matcher and to extract the derivation. The functions are matcher, 
*  separate_rules and get_derivation. 
*  The get_derivation function starts deriving by picking the top most (left most in the parse tree, chosen by the separate_rules function)
*  rule of the rhs associated with the start symbol. If no match is found for the prefix, the next rule in the rhs is taken and the same 
*  steps are carried out.
*  The matcher compares the derivation from the get_dervation function with Some(x,y) and returns Some(x,y) if a match is found else it
*  recurses on the remaining rules in the rhs.
*  
* 
*)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal ;;


let rec get_derivation rulesFunction hrhs accept d frag = if hrhs =[] then accept d frag else 
				match frag with 
				[] -> None
				|prefix::suffix -> match hrhs with
						(T t)::restRhs-> if prefix=t then get_derivation rulesFunction restRhs accept d suffix else None
						|(N n)::restRhs -> 
						(matcher rulesFunction n (get_derivation rulesFunction restRhs accept) d frag)
and
				
 separate_rules rulesFunction startSymbol rhs accept d frag = match rhs with 
				[] -> None
				| h::t -> match (get_derivation rulesFunction h accept (d@[(startSymbol,h)]) frag) with 
							Some (x,y) -> Some (x,y)
							|None -> separate_rules rulesFunction startSymbol t accept d frag
		
and
 matcher rulesFunction startSymbol accept d frag=separate_rules rulesFunction startSymbol (rulesFunction startSymbol) accept d frag ;;



let parse_prefix gram accept frag= match gram with (startSymbol, rulesFunction) ->
matcher rulesFunction startSymbol accept [] frag;;







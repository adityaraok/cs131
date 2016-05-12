

kenken(N,C,T):-
	create_matrix(N,T), maplist(set_domain(N),T), maplist(parse_cages(T),C),
	maplist(fd_all_different,T), transpose(T,Ttran),
	maplist(fd_all_different,Ttran), maplist(fd_labeling, T).
	


set_domain(N,L):- fd_domain(L,1,N).


create_matrix(N,T):-
	generate_row(N,T),
	generate_column(T,N).

generate_row(N,T):-
	length(T,N).

generate_column(T,N):-
	maplist(generate_row(N),T).

parse_cages(T,L):- parse_operation(L,T).
	parse_operation(+(Result,JK), T):- addition(Result,JK,0,T).
	parse_operation(*(Result,JK),T):-multiplication(Result,JK,1,T).
	parse_operation(/(Result,JK1,JK2),T):- division(Result,JK1,JK2,T).
	parse_operation(-(Result,JK1,JK2),T):-subtraction(Result,JK1,JK2,T).
	


multiplication(P,[],P,_).
multiplication(P,[First|Rest],Acc,T):-
	value_at(First,T,Value), Sub_Acc#=Value*Acc, 
	multiplication(P,Rest,Sub_Acc,T).

addition(S,[],S,_).
addition(S,[First|Rest],Acc,T):-
	value_at(First,T,Value), 
	Sub_Acc#=Value+Acc, 
	addition(S,Rest,Sub_Acc,T).

division(Q,_,_,_,Q).
division(Q,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2), 
	Q1#= Value1/Value2,
	division(Q,J,K,T,Q1).

division(Q,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2),  
	 Q1#= Value2/Value1,
	 division(Q,J,K,T,Q1).

subtraction(D,_,_,_,D).
subtraction(D,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2), 
	D1#= Value1-Value2,
	subtraction(D,J,K,T,D1). 

subtraction(D,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2),
	 D1#= Value2-Value1,
	 subtraction(D,J,K,T,D1).



value_at(M-N,T,Value):-
	nth(M,T,X),nth(N,X,Value).
	



transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).





/*


% Plain kenken
% I used the built in function to generate all permutations of a generated sequence.
% The rest is similar to kenken above.
%
%
*/


plain_kenken(N,C,T):-
	create_matrix(N,T), numbers(N,L),maplist(permutation(L), T),
	maplist(different,T), transpose(T,Ttran),
	maplist(different,Ttran),maplist(parse_cages(T),C).

different([_]).
different([H|T]):-
	\+ member(H,T),different(T).	

numbers(N, L) :-
    findall(Number, between(1,N,Number), L).



create_matrix(N,T):-
	generate_row(N,T),
	generate_column(T,N).

generate_row(N,T):-
	length(T,N).

generate_column(T,N):-
	maplist(generate_row(N),T).

parse_cages(T,L):- parse_operation(L,T).
	parse_operation(+(Result,JK), T):- addition(Result,JK,0,T).
	parse_operation(*(Result,JK),T):-multiplication(Result,JK,1,T).
	parse_operation(/(Result,JK1,JK2),T):- division(Result,JK1,JK2,T).
	parse_operation(-(Result,JK1,JK2),T):-subtraction(Result,JK1,JK2,T).
	


multiplication(P,[],P,_).
multiplication(P,[First|Rest],Acc,T):-
	value_at(First,T,Value), Sub_Acc is Value*Acc, 
	multiplication(P,Rest,Sub_Acc,T).

addition(S,[],S,_).
addition(S,[First|Rest],Acc,T):-
	value_at(First,T,Value), 
	Sub_Acc is Value+Acc, 
	addition(S,Rest,Sub_Acc,T).

division(Q,_,_,_,Q).
division(Q,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2), 
	Q1 is Value1/Value2,
	division(Q,J,K,T,Q1).

division(Q,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2),  
	 Q1 is Value2/Value1,
	 division(Q,J,K,T,Q1).

subtraction(D,_,_,_,D).
subtraction(D,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2), 
	D1 is  Value1-Value2,
	subtraction(D,J,K,T,D1). 

subtraction(D,J,K,T):-
	value_at(J,T,Value1),value_at(K,T,Value2),
	 D1 is Value2-Value1,
	 subtraction(D,J,K,T,D1).



value_at(M-N,T,Value):-
	nth(M,T,X),nth(N,X,Value).
	



transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

/*
%
% %noop_kenken(N,C,T):-
%	%This function should check for domain and all different conditions. 
%	
%	%op_decider(C,T):-
%		%I would first look at the list of squares ([2-2,3-2...] etc) to determine
%		%the operators to be checked. For Eg. if there are only two squares all
%		%operations(+,-,/,*) need to be checked. If the no.of squares is more than 
%		%2 then only addition,subtraction and multiplication would suffice 
%		%(However, if successive division is allowed then this is invalid).
%		%I would check for all operations on the list of squares given, the program 
%		%would take exponential time (as it would fully explore the search tree).
%		%The rest of the functions (auxillary) the same as plain_kenken and/or kenken.
*/


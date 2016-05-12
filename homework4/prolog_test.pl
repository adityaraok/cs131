likes(dan,sally).
likes(sally,dan).

dating(X,Y):-
likes(X,Y), 
likes(Y,X).













% --------------------------------------------
% kenken/3
%  N, nonnegative integer
%  C, list of numeric constraints 
%  T, list of list of integers from 1 to N inclusively
% Solves 6x6 in ~1 ms
% --------------------------------------------

% Constraints
%  1) List of given contraints C
%  2) All rows have length_ N
%  3) Elements in row are distinct
%  4) Elements in column are distinct

kenken(N, C, T) :-
	length(T, N), maplist(checkLength(N), T),
	maplist(setDomain(N), T),
	maplist(constraints(T), C),
	maplist(fd_all_different, T),
	transpose(T, T_transposed), maplist(fd_all_different, T_transposed),
	maplist(fd_labeling, T).

% checkLength(Length, Item)
checkLength(Length, Item) :- length(Item, Length).

% Set domain
setDomain(N, L) :- fd_domain(L, 1, N).

% Constraints
constraints(T, C) :- matchConstraint(T, C).
matchConstraint(T, +(S, L)) :- addition(T, S, L, 0).
matchConstraint(T, -(D, J, K)) :- subtraction(T, D, J, K).
matchConstraint(T, *(P, L)) :- multiplication(T, P, L, 1).
matchConstraint(T, /(Q, J, K)) :- division(T, Q, J, K).

% Addition
addition(_, S, [], S).
addition(T, S, [H|Tail], Accumulator) :- 
	matrixElement(H, T, V), 
	New_accumulator #= Accumulator + V, 
	addition(T, S, Tail, New_accumulator). 

% Subtraction
subtraction(_, D, _, _, D).
subtraction(T, D, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator #=  V_1 - V_2,
	subtraction(T, D, J, K, New_accumulator).
subtraction(T, D, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator #=  V_2 - V_1,
	subtraction(T, D, J, K, New_accumulator).

% Multiplication
multiplication(_, P, [], P).
multiplication(T, P, [H|Tail], Accumulator) :-
	matrixElement(H, T, V),
	New_accumulator #= Accumulator * V,
	multiplication(T, P, Tail, New_accumulator).

% Division
division(_, Q, _, _, Q).
division(T, Q, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator #= V_1 / V_2,
	division(T, Q, J, K, New_accumulator).
division(T, Q, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator #= V_2 / V_1,
	division(T, Q, J, K, New_accumulator).

% Matrix element
matrixElement(I_row-J_col, T, Value) :- nth(I_row, T, Row), nth(J_col, Row, Value).

% Transpose, leveraged from clpfd.pl module in SWI-Prolog
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

% --------------------------------------------
% plain_kenken/3 (without using finite domain)
% Solves 4x4 in ~1.3 sec
% --------------------------------------------

% plain_kenken/3
plain_kenken(N, C, T) :-
	length(T, N), maplist(checkLength(N), T),
	domainList(N, L), maplist(permutation(L), T),
	transpose(T, T_transposed), maplist(allDifferent, T_transposed),
	maplist(constraints(T), C).

% Constraints (Plain)
constraints_p(T, C) :- matchConstraint_p(T, C).
matchConstraint_p(T, +(S, L)) :- addition_p(T, S, L, 0).
matchConstraint_p(T, -(D, J, K)) :- subtraction_p(T, D, J, K).
matchConstraint_p(T, *(P, L)) :- multiplication_p(T, P, L, 1).
matchConstraint_p(T, /(Q, J, K)) :- division_p(T, Q, J, K).

% Addition
addition_p(_, S, [], S).
addition_p(T, S, [H|Tail], Accumulator) :- 
	matrixElement(H, T, V), 
	New_accumulator is Accumulator + V, 
	addition_p(T, S, Tail, New_accumulator). 

% Subtraction
subtraction_p(_, D, _, _, D).
subtraction_p(T, D, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator is  V_1 - V_2,
	subtraction_p(T, D, J, K, New_accumulator).
subtraction_p(T, D, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator is  V_2 - V_1,
	subtraction_p(T, D, J, K, New_accumulator).

% Multiplication
multiplication_p(_, P, [], P).
multiplication_p(T, P, [H|Tail], Accumulator) :-
	matrixElement(H, T, V),
	New_accumulator is Accumulator * V,
	multiplication_p(T, P, Tail, New_accumulator).

% Division
division_p(_, Q, _, _, Q).
division_p(T, Q, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator is V_1 / V_2,
	division_p(T, Q, J, K, New_accumulator).
division_p(T, Q, J, K) :-
	matrixElement(J, T, V_1),
	matrixElement(K, T, V_2),
	New_accumulator is V_2 / V_1,
	division_p(T, Q, J, K, New_accumulator).

domainList(N, L) :- findall(Num, between(1, N, Num), L).

% Method 2, slow, does not work on 4x4
%setDomain_p(N, L) :- maplist(range(1, N), L).
%range(Low, High, Low).
%range(Low, High, Out) :- NewLow is Low+1, NewLow =< High, range(NewLow, High, Out).

% Check list elements are unique
allDifferent([]).
allDifferent([H|T]) :- \+(member(H, T)), allDifferent(T).

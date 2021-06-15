
% Smith : Cooper was a friend of Jones and Williams disliked him.
declare(smith, friend(jones)).  
declare(smith, enemy(williams)).

% Jones: I dont know Cooper and he was out of town that day.
declare(jones, stranger(jones)).
declare(jones, outtown(jones)).

% Williams: I saw both Smith and Jones with Cooper.
declare(williams, intown(williams)). 
declare(williams, intown(smith)).
declare(williams, intown(jones)).

% Contradictory expressions.
opposite(outtown(X), intown(X)).
opposite(friend(X), enemy(X)).
opposite(friend(X), stranger(X)).
opposite(enemy(X), stranger(X)).


% Gives all combinations of the given list as another list.
combs([],[]).
combs([H|T], [H|T2]) :-
	combs(T,T2).
combs([_|T],T2) :-
	combs(T,T2).

% Removes elements of the given list recursively from the other list.
remove_list([], _, []).
remove_list([X|Tail], L2, Result) :-
	member(X, L2), !, 
	remove_list(Tail, L2, Result). 
remove_list([X|Tail], L2, [X|Result]) :- 
	remove_list(Tail, L2, Result).

% Checks if the declarings of the given persons are opposite.(Means at least one of them must be lying.)
inequal(W) :-
	member(X,W),  
	member(Y,W),
	X \= Y,	       
	declare(X,XT), 
	declare(Y,YT),
	(
	(length(W,3),test_third(W,X,Y,XT,YT))
	;
	(\+length(W,3),opposite(XT,YT))
	).

% If the given list W in inequal has 3 persons, test_third compares third persons declarings with others.
test_third(W,X,Y,XT,YT) :-
	remove_list(W,[X,Y],Z),
	declare(Z,ZT),
	opposite(ZT,XT);
	opposite(XT,YT).

% Checks if the declarings are consistent.
equal(W) :-
	\+ inequal(W).

% Finds every possible murderers.
findall_murderers(M) :-
	combs([smith, jones, williams],C),
	member(M,[C]),
	possible_murderer(M).

% Checks if the given M is a possible murderer.
% If Ms declarings are not equal, 
% or its declarings are equal but also rest of the lists declarings are equal,
% M might be a possible murderer.
possible_murderer(M) :-
	\+equal(M); 
	(equal(M),
	remove_list([smith, jones, williams],M,P),
	equal(P)
	).

% Determine who the murderer was if one of the three men is guilty, the two innocent 
% men are telling the truth, but the statements of the guilty man may or may not be true.
% Select a Murderer from the list, and rest of the declarings must be equal.
% Since there is only one guilty, 'cut' predicate is used.
murderer_a(M) :-
	member(M, [smith, jones, williams]),
	select(M, [smith, jones, williams], Innocent), 				  
	equal(Innocent),!. 

% Determine who the murderer was if innocent men do not lie.
% Finds all possiblities of murderers, and if there are more than 1 possibility
% it fails since an innocent cannot be guilty at the same time.
murderer_b(M) :-
	setof(M,findall_murderers(M),Set),
	(\+length(Set,1), !, fail).


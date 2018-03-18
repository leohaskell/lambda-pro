:- module(evaluate,
  [ evaluate_input/6
  ]).

:- use_module(terms, [atom_term/2, eq/2]).
:- use_module(reduction, [b_reduce/2, e_reduce/2]).
:- use_module(helpers, [atom_de_bruijn/2, atom_de_bruijn/3]).
:- use_module(utils, [atom_list_concat/2]).

evaluate_input(In, Out, Bs, Ns, Bsi, Nsi) :-
  evaluate_quit(In, Out);
  evaluate_reduction(In, Out, Bs, Ns, Bsi, Nsi, b_reduce);
  evaluate_reduction(In, Out, Bs, Ns, Bsi, Nsi, e_reduce);
  evaluate_equivalence(In, Out, Bs, Ns, Bsi, Nsi);
  evaluate_lambda(In, Out, Bs, Ns, Bsi, Nsi);
  evaluate_bad_input(In, Out), Ns = Nsi, Bs = Bsi.

% Exit if the user has entered 'quit'
evaluate_quit(quit, _) :- halt.

% Store and show a λ-term with its corresponding name and
% version with de Bruijn indices
evaluate_lambda(A, Out, Bs, Ns, Bs, Ns) :-
  get_assoc(A, Bs, (Ti, Tii)),
  atom_term(Ai, Ti), atom_term(Aii, Tii),
  show_terms(A, Ai, Aii, Out), !.
evaluate_lambda(A, Out, Bs, Ns, Bsi, Nsi) :-
  evaluate_(A, _, Out, Bs, Ns, Bsi, Nsi).

% This is used to optimise the number of conversions
% between the formats
evaluate_(A, Ti, Out, Bs, [N|Ns], Bsi, Ns) :-
  atom_de_bruijn(A, T, Ti),
  put_assoc(N, Bs, (T, Ti), Bsi),
  atom_term(Ai, Ti),
  show_terms(N, A, Ai, Out).

% Show a λ-term with its corresponding name and
% version with de Bruijn indices
show_terms(N, A, Ai, S) :-
  atom_list_concat([N, ' = ', A, '\n(de Bruijn) ', Ai], S).

evaluate_reduction(In, Outi, Bs, Ns, Bsi, Nsi, Reduce) :-
  x_reduction(Reduce, In, A), atom_de_bruijn(A, N),
  call(Reduce, N, Ni), evaluate_(Ai, Ni, Out, Bs, Ns, Bsi, Nsi),
  atom_reduce(R, Reduce),
  atom_list_concat([A, R, Ai, '\n', Out], Outi).

atom_reduce(' -β> ', b_reduce).
atom_reduce(' -η> ', e_reduce).

x_reduction(X, A, Ai) :-
  atom_chars(A, CS), once(phrase(x_reduction(X, As), CS)),
  atom_list_concat(As, Ai).

x_reduction(b_reduce, A) --> [b, e, t, a, ' '|A].
x_reduction(e_reduce, A) --> [e, t, a, ' '|A].

evaluate_equivalence(In, Out, Bs, Ns, Bs, Ns) :-
  equivalence(In, Mf, Nf),
  get_assoc(Mf, Bs, (M, Mi)), get_assoc(Nf, Bs, (N, Ni)),
  atom_term(Ma, M), atom_term(Na, N),
  (eq(Mi, Ni) -> Eq = true; Eq = false),
  atom_list_concat([Ma, ' =α= ', Na, '\n', Eq, '\n'], Out).

equivalence(A, M, N) :-
  atom_chars(A, CS), once(phrase(equivalence(Ms, Ns), CS)),
  atom_list_concat(Ms, M), atom_list_concat(Ns, N).

equivalence([C|Cs], N) --> [C], equivalence(Cs, N), { C \= ' ' }.
equivalence([], N) --> [' ', =, =, ' '|N].

% Dislay a message if the input isn't valid
evaluate_bad_input(In, Out) :-
  atom_list_concat(['Bad input: ', In], Out).

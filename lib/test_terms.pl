:- module(test_terms, [term/4]).


term(i, name, atom, 'x. x').
term(i, name, lambda, lambda(x, x)).
term(i, de_bruijn, atom, 'λ 0').
term(i, de_bruijn, lambda, lambda(0)).

term(k, name, atom, 'x. y. x').
term(k, name, lambda, lambda(x, lambda(y, x))).
term(k, de_bruijn, atom, 'λ λ 1').
term(k, de_bruijn, lambda, lambda(lambda(1))).

term(s, name, atom, 'x. y. z. (x z) (y z)').
term(s, name, lambda, lambda(x, lambda(y, lambda(z,
  application(parentheses(application(x, z)),
              parentheses(application(y, z))))))).
term(s, de_bruijn, atom, 'λ λ λ (2 0) (1 0)').
term(s, de_bruijn, lambda, lambda(lambda(lambda(
  application(parentheses(application(2, 0)),
              parentheses(application(1, 0))))))).

term(42, name, atom, 'x. fortytwo').
term(42, name, lambda, lambda(x, fortytwo)).
term(42, de_bruijn, atom, 'λ 43').
term(42, de_bruijn, lambda, lambda(43)).

term(c0, name, atom, 'f. x. x').
term(c0, name, lambda, lambda(f, lambda(x, x))).
term(c0, de_bruijn, atom, 'λ λ 0').
term(c0, de_bruijn, lambda, lambda(lambda(0))).

term(c1, name, atom, 'f. x. f x').
term(c1, name, lambda, lambda(f, lambda(x, application(f, x)))).
term(c1, de_bruijn, atom, 'λ λ 1 0').
term(c1, de_bruijn, lambda, lambda(lambda(application(1, 0)))).
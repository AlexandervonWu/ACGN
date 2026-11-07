sig A { r: set A }
pred lhs { all a: A | a not in (a.r).^r }
pred rhs { all a: A | a not in a.^r }

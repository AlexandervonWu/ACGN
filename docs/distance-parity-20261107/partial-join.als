sig A { r: set B }
sig B { s: C -> D }
sig C {}
sig D {}
pred lhs { some r.(s.D.C) }
pred rhs { some (r.s).D.C }
check same { lhs iff rhs } for 4

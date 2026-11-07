sig A { r: set B }
sig B { s: C -> D }
sig C {}
sig D {}
pred lhs { some A.r }
pred rhs { some A.s }

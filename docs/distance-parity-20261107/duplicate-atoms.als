sig P {}
sig A, B in P {}
pred lhs { all p: P | p not in A or p not in B }
pred rhs { all p: P | (p in A implies p not in B) and (p in B implies p not in A) }
check same { lhs iff rhs } for 4

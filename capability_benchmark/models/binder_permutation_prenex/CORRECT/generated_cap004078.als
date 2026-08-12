sig Node {
	adj : set Node
}
pred inv3 {
all n : Node | n not in n.^adj

no (^adj & iden)

iden - ^adj = iden
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004078 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
pred cap004078c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap004078 { cap004078 iff cap004078c }
check CapBenchEquivalent_cap004078 for 4

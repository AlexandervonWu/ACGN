sig Node {
	adj : set Node
}
pred inv3 {
all n:Node | n not in n.^adj
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

pred cap001650 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA))) }
pred cap001650c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001650 { cap001650 iff cap001650c }
check CapBenchEquivalent_cap001650 for 4

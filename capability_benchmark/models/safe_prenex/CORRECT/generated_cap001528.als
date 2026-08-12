sig Node {
	adj : set Node
}
pred inv8 {
all a,b,c : Node | c in b.adj and b in a.adj implies c in a.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001528 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
pred cap001528c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001528 { cap001528 iff cap001528c }
check CapBenchEquivalent_cap001528 for 4

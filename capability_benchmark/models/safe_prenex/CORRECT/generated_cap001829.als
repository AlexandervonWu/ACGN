sig Node {
	adj : set Node
}
pred inv2 {
no iden & adj.adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001829 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
pred cap001829c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001829 { cap001829 iff cap001829c }
check CapBenchEquivalent_cap001829 for 4

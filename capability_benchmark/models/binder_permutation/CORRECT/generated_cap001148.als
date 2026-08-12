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

pred cap001148 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
pred cap001148c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001148 { cap001148 iff cap001148c }
check CapBenchEquivalent_cap001148 for 4

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

pred cap003143 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap003143c { all renamed: CapBenchA | (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003143 { cap003143 iff cap003143c }
check CapBenchEquivalent_cap003143 for 4

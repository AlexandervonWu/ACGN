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

pred cap003253 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003253c { all renamed: CapBenchA | (((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003253 { cap003253 iff cap003253c }
check CapBenchEquivalent_cap003253 for 4

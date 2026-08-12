sig Node {
	adj : set Node
}
pred inv1 {
all n,m: Node | m in n.adj => n in m.adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003953 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap003953c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003953 { cap003953 iff cap003953c }
check CapBenchEquivalent_cap003953 for 4

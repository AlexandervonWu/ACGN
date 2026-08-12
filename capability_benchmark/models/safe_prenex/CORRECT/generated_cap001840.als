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

pred cap001840 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
pred cap001840c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap001840 { cap001840 iff cap001840c }
check CapBenchEquivalent_cap001840 for 4

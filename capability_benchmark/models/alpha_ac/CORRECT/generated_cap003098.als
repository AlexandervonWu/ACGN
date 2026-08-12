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

pred cap003098 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)) }
pred cap003098c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003098 { cap003098 iff cap003098c }
check CapBenchEquivalent_cap003098 for 4

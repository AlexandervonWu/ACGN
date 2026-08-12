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

pred cap001513 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchA))) }
pred cap001513c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001513 { cap001513 iff cap001513c }
check CapBenchEquivalent_cap001513 for 4

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

pred cap003142 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap003142c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003142 { cap003142 iff cap003142c }
check CapBenchEquivalent_cap003142 for 4

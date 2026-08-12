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

pred cap004558 { not ((inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) }
pred cap004558c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) or (not (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004558 { cap004558 iff cap004558c }
check CapBenchEquivalent_cap004558 for 4

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

pred cap004538 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) and ((no CapBenchB or no CapBenchA) and no CapBenchB)) }
pred cap004538c { ((not ((no CapBenchB or no CapBenchA) and no CapBenchB)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004538 { cap004538 iff cap004538c }
check CapBenchEquivalent_cap004538 for 4

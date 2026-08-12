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

pred cap004586 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)) and ((no CapBenchB or some CapBenchA) and some capBenchR)) }
pred cap004586c { ((not ((no CapBenchB or some CapBenchA) and some capBenchR)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004586 { cap004586 iff cap004586c }
check CapBenchEquivalent_cap004586 for 4

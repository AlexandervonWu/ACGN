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

pred cap000519 { ((inv2 and ((no CapBenchB or no CapBenchA) and some CapBenchA)) or ((some CapBenchA and some CapBenchA) or no CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) }
pred cap000519c { (((some CapBenchA and some CapBenchA) or no CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS) or (inv2 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000519 { cap000519 iff cap000519c }
check CapBenchEquivalent_cap000519 for 4

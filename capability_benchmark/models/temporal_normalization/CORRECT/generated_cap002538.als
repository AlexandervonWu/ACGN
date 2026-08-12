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

pred cap002538 { not historically ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
pred cap002538c { once (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap002538 { cap002538 iff cap002538c }
check CapBenchEquivalent_cap002538 for 4

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

pred cap002693 { not eventually ((inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
pred cap002693c { always (not (inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002693 { cap002693 iff cap002693c }
check CapBenchEquivalent_cap002693 for 4

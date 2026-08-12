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

pred cap002645 { not eventually ((inv2 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap002645c { always (not (inv2 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002645 { cap002645 iff cap002645c }
check CapBenchEquivalent_cap002645 for 4

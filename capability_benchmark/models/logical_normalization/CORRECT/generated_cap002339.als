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

pred cap002339 { ((inv2 and ((no CapBenchB or no CapBenchA) and some capBenchS)) iff ((some CapBenchA and some CapBenchA) or some CapBenchA)) }
pred cap002339c { (((not (inv2 and ((no CapBenchB or no CapBenchA) and some capBenchS))) or ((some CapBenchA and some CapBenchA) or some CapBenchA)) and ((not ((some CapBenchA and some CapBenchA) or some CapBenchA)) or (inv2 and ((no CapBenchB or no CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap002339 { cap002339 iff cap002339c }
check CapBenchEquivalent_cap002339 for 4

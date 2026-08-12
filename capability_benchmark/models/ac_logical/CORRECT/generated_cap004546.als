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

pred cap004546 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) and ((no CapBenchB or no CapBenchB) and no CapBenchB)) }
pred cap004546c { ((not ((no CapBenchB or no CapBenchB) and no CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004546 { cap004546 iff cap004546c }
check CapBenchEquivalent_cap004546 for 4

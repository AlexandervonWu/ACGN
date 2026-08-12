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

pred cap004948 { not ((inv2 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some capBenchS) or some CapBenchB)) }
pred cap004948c { ((not ((some capBenchS or some capBenchS) or some CapBenchB)) or (not (inv2 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004948 { cap004948 iff cap004948c }
check CapBenchEquivalent_cap004948 for 4

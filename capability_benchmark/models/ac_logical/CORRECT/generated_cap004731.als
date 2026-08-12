sig Node {
	adj : set Node
}
pred inv8 {
all n: Node | n.adj.adj in n.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004731 { not ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004731c { ((not ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004731 { cap004731 iff cap004731c }
check CapBenchEquivalent_cap004731 for 4

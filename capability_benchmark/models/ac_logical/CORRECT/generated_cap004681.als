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

pred cap004681 { not ((inv8 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((no CapBenchA and some capBenchR) and some capBenchS)) }
pred cap004681c { ((not ((no CapBenchA and some capBenchR) and some capBenchS)) or (not (inv8 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004681 { cap004681 iff cap004681c }
check CapBenchEquivalent_cap004681 for 4

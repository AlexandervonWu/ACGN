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

pred cap002369 { ((inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) iff ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) }
pred cap002369c { (((not (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) or (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap002369 { cap002369 iff cap002369c }
check CapBenchEquivalent_cap002369 for 4

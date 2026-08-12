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

pred cap003461 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) }
pred cap003461c { all renamed: CapBenchA | (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003461 { cap003461 iff cap003461c }
check CapBenchEquivalent_cap003461 for 4

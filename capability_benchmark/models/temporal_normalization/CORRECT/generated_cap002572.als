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

pred cap002572 { not always ((inv8 and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
pred cap002572c { eventually (not (inv8 and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002572 { cap002572 iff cap002572c }
check CapBenchEquivalent_cap002572 for 4

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

pred cap004103 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap004103c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap004103 { cap004103 iff cap004103c }
check CapBenchEquivalent_cap004103 for 4

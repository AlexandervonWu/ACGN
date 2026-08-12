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

pred cap004132 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchR and some CapBenchA) or no CapBenchA))) }
pred cap004132c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchR and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap004132 { cap004132 iff cap004132c }
check CapBenchEquivalent_cap004132 for 4

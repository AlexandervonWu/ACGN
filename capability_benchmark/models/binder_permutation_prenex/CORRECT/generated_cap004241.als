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

pred cap004241 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap004241c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap004241 { cap004241 iff cap004241c }
check CapBenchEquivalent_cap004241 for 4

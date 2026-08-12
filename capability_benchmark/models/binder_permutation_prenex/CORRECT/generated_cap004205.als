sig Node {
	adj : set Node
}
pred inv8 {
all a,b,c : Node | c in b.adj and b in a.adj implies c in a.adj
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

pred cap004205 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
pred cap004205c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap004205 { cap004205 iff cap004205c }
check CapBenchEquivalent_cap004205 for 4

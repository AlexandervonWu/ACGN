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

pred cap004077 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
pred cap004077c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap004077 { cap004077 iff cap004077c }
check CapBenchEquivalent_cap004077 for 4

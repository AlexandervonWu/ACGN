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

pred cap001534 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
pred cap001534c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001534 { cap001534 iff cap001534c }
check CapBenchEquivalent_cap001534 for 4

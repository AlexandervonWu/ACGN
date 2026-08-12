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

pred cap005151 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) and ((some capBenchR and some CapBenchA) or some capBenchS))) }
pred cap005151c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchA) or some capBenchS)) or (not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005151 { cap005151 iff cap005151c }
check CapBenchEquivalent_cap005151 for 4

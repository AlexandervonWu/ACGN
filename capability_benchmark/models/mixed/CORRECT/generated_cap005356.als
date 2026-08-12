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

pred cap005356 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some capBenchR and some capBenchR) or some capBenchS)) and ((some CapBenchB or no CapBenchA) or some CapBenchA))) }
pred cap005356c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or some CapBenchA)) or (not (inv8 and ((some capBenchR and some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap005356 { cap005356 iff cap005356c }
check CapBenchEquivalent_cap005356 for 4

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

pred cap001577 { ((all x: CapBenchA | x->x in capBenchR) or (inv8 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
pred cap001577c { (all x: CapBenchA | (x->x in capBenchR or (inv8 and ((some capBenchS or some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001577 { cap001577 iff cap001577c }
check CapBenchEquivalent_cap001577 for 4

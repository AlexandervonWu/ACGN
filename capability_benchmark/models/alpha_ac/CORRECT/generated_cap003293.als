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

pred cap003293 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchS or some capBenchR) or some capBenchR)) and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003293c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some capBenchS or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap003293 { cap003293 iff cap003293c }
check CapBenchEquivalent_cap003293 for 4

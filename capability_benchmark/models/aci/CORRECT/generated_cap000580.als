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

pred cap000580 { (inv8 and ((some CapBenchA and no CapBenchA) or some CapBenchB)) }
pred cap000580c { ((inv8 and ((some CapBenchA and no CapBenchA) or some CapBenchB)) and (inv8 and ((some CapBenchA and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000580 { cap000580 iff cap000580c }
check CapBenchEquivalent_cap000580 for 4

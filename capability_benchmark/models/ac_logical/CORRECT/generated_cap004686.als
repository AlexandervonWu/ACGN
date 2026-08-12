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

pred cap004686 { not ((inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) }
pred cap004686c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) or (not (inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004686 { cap004686 iff cap004686c }
check CapBenchEquivalent_cap004686 for 4

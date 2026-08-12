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

pred cap002950 { not always ((inv8 and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002950c { eventually (not (inv8 and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002950 { cap002950 iff cap002950c }
check CapBenchEquivalent_cap002950 for 4

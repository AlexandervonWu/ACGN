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

pred cap002647 { not once ((inv8 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap002647c { historically (not (inv8 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002647 { cap002647 iff cap002647c }
check CapBenchEquivalent_cap002647 for 4

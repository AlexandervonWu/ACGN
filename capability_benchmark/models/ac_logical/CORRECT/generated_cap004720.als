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

pred cap004720 { not ((inv8 and ((some capBenchR and no CapBenchB) or no CapBenchB)) and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004720c { ((not ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((some capBenchR and no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004720 { cap004720 iff cap004720c }
check CapBenchEquivalent_cap004720 for 4

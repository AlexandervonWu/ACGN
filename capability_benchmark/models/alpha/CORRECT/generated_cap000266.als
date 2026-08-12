sig Node {
	adj : set Node
}
pred inv1 {
adj = ~adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000266 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
pred cap000266c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000266 { cap000266 iff cap000266c }
check CapBenchEquivalent_cap000266 for 4

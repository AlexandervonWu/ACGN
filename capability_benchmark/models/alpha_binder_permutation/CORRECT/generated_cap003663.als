sig Node {
	adj : set Node
}
pred inv7 {
all n:Node | Node in n.*adj
}

pred inv7c {
	all n:Node | Node = n.*adj
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003663 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap003663c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003663 { cap003663 iff cap003663c }
check CapBenchEquivalent_cap003663 for 4

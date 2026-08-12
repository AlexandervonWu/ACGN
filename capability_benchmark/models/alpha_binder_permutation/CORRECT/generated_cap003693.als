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

pred cap003693 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
pred cap003693c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003693 { cap003693 iff cap003693c }
check CapBenchEquivalent_cap003693 for 4

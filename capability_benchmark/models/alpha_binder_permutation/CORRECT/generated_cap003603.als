sig Node {
	adj : set Node
}
pred inv7 {
all n1,n2:Node | n2 in n1.*adj
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

pred cap003603 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap003603c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003603 { cap003603 iff cap003603c }
check CapBenchEquivalent_cap003603 for 4

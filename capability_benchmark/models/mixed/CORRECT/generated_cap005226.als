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

pred cap005226 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchA and some capBenchR) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005226c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv7 and ((no CapBenchA and some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005226 { cap005226 iff cap005226c }
check CapBenchEquivalent_cap005226 for 4

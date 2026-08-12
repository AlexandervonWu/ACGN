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

pred cap005187 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((some CapBenchA and some capBenchS) or some capBenchS))) }
pred cap005187c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchS) or some capBenchS)) or (not (inv7 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005187 { cap005187 iff cap005187c }
check CapBenchEquivalent_cap005187 for 4

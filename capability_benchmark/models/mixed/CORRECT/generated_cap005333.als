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

pred cap005333 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some capBenchS or some CapBenchB) or some capBenchS)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005333c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv7 and ((some capBenchS or some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005333 { cap005333 iff cap005333c }
check CapBenchEquivalent_cap005333 for 4

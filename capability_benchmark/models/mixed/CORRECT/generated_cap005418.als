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

pred cap005418 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB))) }
pred cap005418c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB)) or (not (inv7 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005418 { cap005418 iff cap005418c }
check CapBenchEquivalent_cap005418 for 4

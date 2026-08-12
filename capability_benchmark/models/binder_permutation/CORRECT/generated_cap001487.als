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

pred cap001487 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001487c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001487 { cap001487 iff cap001487c }
check CapBenchEquivalent_cap001487 for 4

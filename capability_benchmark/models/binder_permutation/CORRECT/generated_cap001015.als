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

pred cap001015 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap001015c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap001015 { cap001015 iff cap001015c }
check CapBenchEquivalent_cap001015 for 4

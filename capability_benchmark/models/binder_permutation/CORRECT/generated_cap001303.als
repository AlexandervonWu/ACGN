var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001303 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
pred cap001303c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap001303 { cap001303 iff cap001303c }
check CapBenchEquivalent_cap001303 for 4

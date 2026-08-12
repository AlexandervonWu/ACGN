var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv19 {
always all f : Protected | f in Protected until f in Trash
}

pred inv19c {
	always all f : Protected | f in Protected until f in Trash
}

check correct { inv19 <=> inv19c}
pred under { inv19 and !inv19c}
pred over { !inv19 and inv19c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001135 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv19 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap001135c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv19 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap001135 { cap001135 iff cap001135c }
check CapBenchEquivalent_cap001135 for 4

var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File

some File'
}

pred inv2c {
	no File
  	some File'
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001239 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap001239c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap001239 { cap001239 iff cap001239c }
check CapBenchEquivalent_cap001239 for 4

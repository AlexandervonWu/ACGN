var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always no Trash & Protected
}

pred inv9c {
	always no Protected & Trash
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001221 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv9 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
pred cap001221c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv9 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap001221 { cap001221 iff cap001221c }
check CapBenchEquivalent_cap001221 for 4

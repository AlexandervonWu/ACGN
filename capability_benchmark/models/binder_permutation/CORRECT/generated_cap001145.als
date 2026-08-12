var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : (File&Trash) | once f not in Trash
}

pred inv13c {
	always (all f:Trash | once f not in Trash)
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001145 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv13 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap001145c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv13 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001145 { cap001145 iff cap001145c }
check CapBenchEquivalent_cap001145 for 4

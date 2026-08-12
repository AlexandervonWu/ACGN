var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f: (File - Protected) | after f in Protected
}

pred inv11c {
	always File-Protected in Protected'
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001417 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv11 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001417c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv11 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001417 { cap001417 iff cap001417c }
check CapBenchEquivalent_cap001417 for 4

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

pred cap004171 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv11 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap004171c { some a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap004171 { cap004171 iff cap004171c }
check CapBenchEquivalent_cap004171 for 4

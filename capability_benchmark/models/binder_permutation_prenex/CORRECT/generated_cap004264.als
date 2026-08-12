var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always (all f : File | f not in Protected implies after f in Protected)
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

pred cap004264 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv11 and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
pred cap004264c { some a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap004264 { cap004264 iff cap004264c }
check CapBenchEquivalent_cap004264 for 4

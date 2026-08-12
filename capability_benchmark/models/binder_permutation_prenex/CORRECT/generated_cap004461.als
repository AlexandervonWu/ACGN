var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f : File | f not in Protected implies after f in Protected
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

pred cap004461 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv11 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004461c { some a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004461 { cap004461 iff cap004461c }
check CapBenchEquivalent_cap004461 for 4

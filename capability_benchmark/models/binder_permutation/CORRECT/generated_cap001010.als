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

pred cap001010 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
pred cap001010c { all a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap001010 { cap001010 iff cap001010c }
check CapBenchEquivalent_cap001010 for 4

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

pred cap001703 { ((all x: CapBenchA | x->x in capBenchR) or (inv11 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap001703c { (all x: CapBenchA | (x->x in capBenchR or (inv11 and ((no CapBenchB or some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001703 { cap001703 iff cap001703c }
check CapBenchEquivalent_cap001703 for 4

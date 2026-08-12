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

pred cap001511 { ((all x: CapBenchA | x->x in capBenchR) or (inv11 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap001511c { (all x: CapBenchA | (x->x in capBenchR or (inv11 and ((no CapBenchB or some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001511 { cap001511 iff cap001511c }
check CapBenchEquivalent_cap001511 for 4

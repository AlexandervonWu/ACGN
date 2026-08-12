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

pred cap001989 { ((all x: CapBenchA | x->x in capBenchR) or (inv11 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001989c { (all x: CapBenchA | (x->x in capBenchR or (inv11 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001989 { cap001989 iff cap001989c }
check CapBenchEquivalent_cap001989 for 4

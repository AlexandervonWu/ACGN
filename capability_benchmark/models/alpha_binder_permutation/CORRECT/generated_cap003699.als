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

pred cap003699 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap003699c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003699 { cap003699 iff cap003699c }
check CapBenchEquivalent_cap003699 for 4

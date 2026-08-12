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

pred cap003520 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
pred cap003520c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003520 { cap003520 iff cap003520c }
check CapBenchEquivalent_cap003520 for 4

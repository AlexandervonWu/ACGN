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

pred cap003513 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some capBenchS or some CapBenchB) or some CapBenchA))) }
pred cap003513c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((some capBenchS or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003513 { cap003513 iff cap003513c }
check CapBenchEquivalent_cap003513 for 4

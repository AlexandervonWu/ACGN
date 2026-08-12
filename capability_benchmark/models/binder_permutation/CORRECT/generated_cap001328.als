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

pred cap001328 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
pred cap001328c { all a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap001328 { cap001328 iff cap001328c }
check CapBenchEquivalent_cap001328 for 4

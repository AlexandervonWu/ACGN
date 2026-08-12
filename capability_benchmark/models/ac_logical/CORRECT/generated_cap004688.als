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

pred cap004688 { not ((inv11 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((some CapBenchB or some capBenchS) or some capBenchS)) }
pred cap004688c { ((not ((some CapBenchB or some capBenchS) or some capBenchS)) or (not (inv11 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004688 { cap004688 iff cap004688c }
check CapBenchEquivalent_cap004688 for 4

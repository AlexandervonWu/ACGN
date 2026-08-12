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

pred cap004661 { not ((inv11 and ((some CapBenchB or some capBenchR) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)) }
pred cap004661c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)) or (not (inv11 and ((some CapBenchB or some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004661 { cap004661 iff cap004661c }
check CapBenchEquivalent_cap004661 for 4

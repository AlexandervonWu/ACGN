var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004856 { not ((inv4 and ((some capBenchR and some capBenchR) or some capBenchS)) and ((some CapBenchB or no CapBenchA) or some CapBenchA)) }
pred cap004856c { ((not ((some CapBenchB or no CapBenchA) or some CapBenchA)) or (not (inv4 and ((some capBenchR and some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap004856 { cap004856 iff cap004856c }
check CapBenchEquivalent_cap004856 for 4

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

pred cap000878 { ((inv4 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA) and ((some capBenchS or no CapBenchA) or no CapBenchB)) }
pred cap000878c { (((some capBenchS or no CapBenchA) or no CapBenchB) and (inv4 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) }
assert CapBenchEquivalent_cap000878 { cap000878 iff cap000878c }
check CapBenchEquivalent_cap000878 for 4

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

pred cap004964 { not ((inv4 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap004964c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (not (inv4 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004964 { cap004964 iff cap004964c }
check CapBenchEquivalent_cap004964 for 4

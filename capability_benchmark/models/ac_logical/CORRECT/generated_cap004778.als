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

pred cap004778 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004778c { ((not ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap004778 { cap004778 iff cap004778c }
check CapBenchEquivalent_cap004778 for 4

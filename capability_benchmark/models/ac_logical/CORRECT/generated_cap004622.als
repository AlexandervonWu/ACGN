var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
no (Trash + Protected)
}

pred inv1c {
	no Trash + Protected
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004622 { not ((inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) }
pred cap004622c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) or (not (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004622 { cap004622 iff cap004622c }
check CapBenchEquivalent_cap004622 for 4

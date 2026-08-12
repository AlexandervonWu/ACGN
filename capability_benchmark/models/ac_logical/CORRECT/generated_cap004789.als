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

pred cap004789 { not ((inv1 and ((some CapBenchB or some capBenchR) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004789c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some CapBenchB or some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap004789 { cap004789 iff cap004789c }
check CapBenchEquivalent_cap004789 for 4

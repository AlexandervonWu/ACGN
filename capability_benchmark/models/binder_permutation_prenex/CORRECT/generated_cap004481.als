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

pred cap004481 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004481c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004481 { cap004481 iff cap004481c }
check CapBenchEquivalent_cap004481 for 4

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

pred cap004188 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap004188c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap004188 { cap004188 iff cap004188c }
check CapBenchEquivalent_cap004188 for 4

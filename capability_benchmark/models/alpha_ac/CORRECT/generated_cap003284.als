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

pred cap003284 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or some capBenchR)) and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003284c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003284 { cap003284 iff cap003284c }
check CapBenchEquivalent_cap003284 for 4

var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
historically (no Trash and no Protected)
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

pred cap003500 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
pred cap003500c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003500 { cap003500 iff cap003500c }
check CapBenchEquivalent_cap003500 for 4

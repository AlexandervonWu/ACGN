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

pred cap001546 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) }
pred cap001546c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001546 { cap001546 iff cap001546c }
check CapBenchEquivalent_cap001546 for 4

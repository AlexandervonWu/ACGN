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

pred cap001040 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
pred cap001040c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap001040 { cap001040 iff cap001040c }
check CapBenchEquivalent_cap001040 for 4

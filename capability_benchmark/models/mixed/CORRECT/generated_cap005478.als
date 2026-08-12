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

pred cap005478 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap005478c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchB) and no CapBenchA)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005478 { cap005478 iff cap005478c }
check CapBenchEquivalent_cap005478 for 4

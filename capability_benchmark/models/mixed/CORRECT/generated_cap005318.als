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

pred cap005318 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005318c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap005318 { cap005318 iff cap005318c }
check CapBenchEquivalent_cap005318 for 4

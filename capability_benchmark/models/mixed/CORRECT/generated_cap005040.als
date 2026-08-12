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

pred cap005040 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and some capBenchS) or some CapBenchA)) and ((some capBenchS or no CapBenchA) or no CapBenchB))) }
pred cap005040c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or no CapBenchB)) or (not (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005040 { cap005040 iff cap005040c }
check CapBenchEquivalent_cap005040 for 4

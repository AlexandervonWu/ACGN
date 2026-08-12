var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005327 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005327c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap005327 { cap005327 iff cap005327c }
check CapBenchEquivalent_cap005327 for 4

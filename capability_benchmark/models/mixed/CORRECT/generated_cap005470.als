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

pred cap005470 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap005470c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchA) and no CapBenchA)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005470 { cap005470 iff cap005470c }
check CapBenchEquivalent_cap005470 for 4

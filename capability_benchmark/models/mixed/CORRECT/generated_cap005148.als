var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually (some f:File | f in Trash)
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

pred cap005148 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA)) and ((some CapBenchB or some CapBenchA) or some capBenchS))) }
pred cap005148c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or some capBenchS)) or (not (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005148 { cap005148 iff cap005148c }
check CapBenchEquivalent_cap005148 for 4

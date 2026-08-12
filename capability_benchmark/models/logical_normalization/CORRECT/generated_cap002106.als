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

pred cap002106 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchS) and some CapBenchB)))) }
pred cap002106c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap002106 { cap002106 iff cap002106c }
check CapBenchEquivalent_cap002106 for 4

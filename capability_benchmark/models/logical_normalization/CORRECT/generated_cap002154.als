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

pred cap002154 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and no CapBenchB) and no CapBenchA)))) }
pred cap002154c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002154 { cap002154 iff cap002154c }
check CapBenchEquivalent_cap002154 for 4

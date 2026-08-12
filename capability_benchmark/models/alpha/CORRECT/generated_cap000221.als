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

pred cap000221 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
pred cap000221c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000221 { cap000221 iff cap000221c }
check CapBenchEquivalent_cap000221 for 4

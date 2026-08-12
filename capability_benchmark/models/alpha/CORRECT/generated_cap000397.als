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

pred cap000397 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000397c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000397 { cap000397 iff cap000397c }
check CapBenchEquivalent_cap000397 for 4

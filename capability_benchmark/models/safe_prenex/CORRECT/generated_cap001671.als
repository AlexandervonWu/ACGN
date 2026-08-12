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

pred cap001671 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap001671c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((no CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001671 { cap001671 iff cap001671c }
check CapBenchEquivalent_cap001671 for 4

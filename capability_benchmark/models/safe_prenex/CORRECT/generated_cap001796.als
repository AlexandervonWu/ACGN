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

pred cap001796 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some CapBenchA and some capBenchS) or some capBenchR))) }
pred cap001796c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap001796 { cap001796 iff cap001796c }
check CapBenchEquivalent_cap001796 for 4

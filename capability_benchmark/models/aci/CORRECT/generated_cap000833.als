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

pred cap000833 { (inv4 and ((some capBenchS or some CapBenchB) or some capBenchS)) }
pred cap000833c { ((inv4 and ((some capBenchS or some CapBenchB) or some capBenchS)) or (inv4 and ((some capBenchS or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000833 { cap000833 iff cap000833c }
check CapBenchEquivalent_cap000833 for 4

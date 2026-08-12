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

pred cap002642 { not (((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA))) until (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap002642c { ((not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA))) releases (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002642 { cap002642 iff cap002642c }
check CapBenchEquivalent_cap002642 for 4

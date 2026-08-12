var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv3 {
always some File
}

pred inv3c {
	always some File
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002990 { not (((inv3 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) until (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap002990c { ((not (inv3 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) releases (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002990 { cap002990 iff cap002990c }
check CapBenchEquivalent_cap002990 for 4

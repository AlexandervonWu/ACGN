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

pred cap002679 { not (((inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) since (((some CapBenchA and some capBenchR) or some capBenchS))) }
pred cap002679c { ((not (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) triggered (not ((some CapBenchA and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap002679 { cap002679 iff cap002679c }
check CapBenchEquivalent_cap002679 for 4

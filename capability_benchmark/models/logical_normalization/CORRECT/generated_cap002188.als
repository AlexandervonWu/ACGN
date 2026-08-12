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

pred cap002188 { ((inv3 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) implies ((some CapBenchB or some capBenchS) or some capBenchS)) }
pred cap002188c { ((not (inv3 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) or ((some CapBenchB or some capBenchS) or some capBenchS)) }
assert CapBenchEquivalent_cap002188 { cap002188 iff cap002188c }
check CapBenchEquivalent_cap002188 for 4

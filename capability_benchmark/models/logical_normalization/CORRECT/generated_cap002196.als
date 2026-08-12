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

pred cap002196 { not (all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or no CapBenchB)))) }
pred cap002196c { some x: CapBenchA | not (x->x in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002196 { cap002196 iff cap002196c }
check CapBenchEquivalent_cap002196 for 4

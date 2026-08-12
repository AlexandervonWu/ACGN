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

pred cap003595 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap003595c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003595 { cap003595 iff cap003595c }
check CapBenchEquivalent_cap003595 for 4

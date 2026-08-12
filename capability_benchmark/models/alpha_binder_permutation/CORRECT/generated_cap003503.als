var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File and after some File
}

pred inv2c {
	no File
  	some File'
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003503 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap003503c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003503 { cap003503 iff cap003503c }
check CapBenchEquivalent_cap003503 for 4

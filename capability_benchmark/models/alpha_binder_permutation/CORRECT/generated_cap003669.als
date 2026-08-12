var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
historically no File and after some File
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

pred cap003669 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
pred cap003669c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap003669 { cap003669 iff cap003669c }
check CapBenchEquivalent_cap003669 for 4

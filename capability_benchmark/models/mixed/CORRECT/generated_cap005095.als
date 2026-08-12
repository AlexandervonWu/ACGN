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

pred cap005095 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)) and ((some capBenchR and some CapBenchB) or some capBenchR))) }
pred cap005095c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchB) or some capBenchR)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005095 { cap005095 iff cap005095c }
check CapBenchEquivalent_cap005095 for 4

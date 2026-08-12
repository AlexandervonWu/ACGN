var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File

some File'
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

pred cap004356 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchR and some capBenchR) or some capBenchS))) }
pred cap004356c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap004356 { cap004356 iff cap004356c }
check CapBenchEquivalent_cap004356 for 4

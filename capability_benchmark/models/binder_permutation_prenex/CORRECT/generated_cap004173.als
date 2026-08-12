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

pred cap004173 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
pred cap004173c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap004173 { cap004173 iff cap004173c }
check CapBenchEquivalent_cap004173 for 4

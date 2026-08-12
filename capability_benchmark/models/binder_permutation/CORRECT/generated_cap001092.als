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

pred cap001092 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchB))) }
pred cap001092c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap001092 { cap001092 iff cap001092c }
check CapBenchEquivalent_cap001092 for 4

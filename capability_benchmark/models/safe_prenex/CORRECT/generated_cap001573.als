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

pred cap001573 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchB))) }
pred cap001573c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001573 { cap001573 iff cap001573c }
check CapBenchEquivalent_cap001573 for 4

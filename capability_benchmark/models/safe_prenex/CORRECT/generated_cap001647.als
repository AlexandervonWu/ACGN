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

pred cap001647 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap001647c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((no CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001647 { cap001647 iff cap001647c }
check CapBenchEquivalent_cap001647 for 4

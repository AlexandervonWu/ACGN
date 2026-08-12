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

pred cap001645 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap001645c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001645 { cap001645 iff cap001645c }
check CapBenchEquivalent_cap001645 for 4

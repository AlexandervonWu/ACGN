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

pred cap001783 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap001783c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((no CapBenchB or no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap001783 { cap001783 iff cap001783c }
check CapBenchEquivalent_cap001783 for 4

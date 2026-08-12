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

pred cap000317 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap000317c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000317 { cap000317 iff cap000317c }
check CapBenchEquivalent_cap000317 for 4

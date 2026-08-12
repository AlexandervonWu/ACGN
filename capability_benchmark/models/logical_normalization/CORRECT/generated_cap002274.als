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

pred cap002274 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and no CapBenchA) and some capBenchR)))) }
pred cap002274c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002274 { cap002274 iff cap002274c }
check CapBenchEquivalent_cap002274 for 4

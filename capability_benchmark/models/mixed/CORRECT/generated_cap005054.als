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

pred cap005054 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((no CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap005054c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some capBenchR) and no CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005054 { cap005054 iff cap005054c }
check CapBenchEquivalent_cap005054 for 4

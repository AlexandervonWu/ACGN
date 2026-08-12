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

pred cap004425 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004425c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004425 { cap004425 iff cap004425c }
check CapBenchEquivalent_cap004425 for 4

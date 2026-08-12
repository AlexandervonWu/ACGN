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

pred cap005196 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and some CapBenchA) or no CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap005196c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv2 and ((some capBenchR and some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005196 { cap005196 iff cap005196c }
check CapBenchEquivalent_cap005196 for 4

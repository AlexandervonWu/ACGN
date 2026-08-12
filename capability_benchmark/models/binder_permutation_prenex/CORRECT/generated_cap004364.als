var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv3 {
always some File
}

pred inv3c {
	always some File
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004364 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some capBenchR and some capBenchS) or some capBenchS))) }
pred cap004364c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some capBenchR and some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap004364 { cap004364 iff cap004364c }
check CapBenchEquivalent_cap004364 for 4

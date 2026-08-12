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

pred cap001865 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((some capBenchS or some capBenchS) or some capBenchS))) }
pred cap001865c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((some capBenchS or some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap001865 { cap001865 iff cap001865c }
check CapBenchEquivalent_cap001865 for 4

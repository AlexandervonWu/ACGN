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

pred cap001738 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
pred cap001738c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001738 { cap001738 iff cap001738c }
check CapBenchEquivalent_cap001738 for 4

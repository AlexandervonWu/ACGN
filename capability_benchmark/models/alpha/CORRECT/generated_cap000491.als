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

pred cap000491 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000491c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000491 { cap000491 iff cap000491c }
check CapBenchEquivalent_cap000491 for 4

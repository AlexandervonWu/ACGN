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

pred cap000263 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap000263c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000263 { cap000263 iff cap000263c }
check CapBenchEquivalent_cap000263 for 4

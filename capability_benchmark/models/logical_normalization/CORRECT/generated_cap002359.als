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

pred cap002359 { no x: CapBenchA | (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
pred cap002359c { all x: CapBenchA | not (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap002359 { cap002359 iff cap002359c }
check CapBenchEquivalent_cap002359 for 4

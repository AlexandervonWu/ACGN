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

pred cap000587 { (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) }
pred cap000587c { ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000587 { cap000587 iff cap000587c }
check CapBenchEquivalent_cap000587 for 4

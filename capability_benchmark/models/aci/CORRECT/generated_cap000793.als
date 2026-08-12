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

pred cap000793 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((some capBenchS or some capBenchR) or some capBenchR))) }
pred cap000793c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((some capBenchS or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap000793 { cap000793 iff cap000793c }
check CapBenchEquivalent_cap000793 for 4

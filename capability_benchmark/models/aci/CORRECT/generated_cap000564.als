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

pred cap000564 { (some ((CapBenchA.capBenchR).capBenchR) and (inv3 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
pred cap000564c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv3 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000564 { cap000564 iff cap000564c }
check CapBenchEquivalent_cap000564 for 4

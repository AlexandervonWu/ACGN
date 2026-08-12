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

pred cap002132 { not not ((inv3 and ((some capBenchR and some CapBenchA) or no CapBenchA))) }
pred cap002132c { (inv3 and ((some capBenchR and some CapBenchA) or no CapBenchA)) }
assert CapBenchEquivalent_cap002132 { cap002132 iff cap002132c }
check CapBenchEquivalent_cap002132 for 4

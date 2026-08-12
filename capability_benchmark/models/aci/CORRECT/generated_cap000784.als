var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
no (Trash + Protected)
}

pred inv1c {
	no Trash + Protected
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000784 { (inv1 and ((some capBenchR and no CapBenchB) or some capBenchR)) }
pred cap000784c { ((inv1 and ((some capBenchR and no CapBenchB) or some capBenchR)) and (inv1 and ((some capBenchR and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000784 { cap000784 iff cap000784c }
check CapBenchEquivalent_cap000784 for 4

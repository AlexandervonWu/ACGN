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

pred cap001653 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some CapBenchB or no CapBenchB) or no CapBenchA))) }
pred cap001653c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some CapBenchB or no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001653 { cap001653 iff cap001653c }
check CapBenchEquivalent_cap001653 for 4

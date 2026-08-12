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

pred cap001679 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap001679c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001679 { cap001679 iff cap001679c }
check CapBenchEquivalent_cap001679 for 4

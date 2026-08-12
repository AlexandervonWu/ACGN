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

pred cap003058 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) }
pred cap003058c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003058 { cap003058 iff cap003058c }
check CapBenchEquivalent_cap003058 for 4

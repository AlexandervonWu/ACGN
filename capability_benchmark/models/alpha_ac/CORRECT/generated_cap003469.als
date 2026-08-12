var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
historically (no Trash and no Protected)
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

pred cap003469 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and some CapBenchA) and no CapBenchA)) }
pred cap003469c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and no CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003469 { cap003469 iff cap003469c }
check CapBenchEquivalent_cap003469 for 4

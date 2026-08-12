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

pred cap003180 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some CapBenchB or some capBenchR) or some capBenchS)) }
pred cap003180c { all renamed: CapBenchA | (((some CapBenchB or some capBenchR) or some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap003180 { cap003180 iff cap003180c }
check CapBenchEquivalent_cap003180 for 4

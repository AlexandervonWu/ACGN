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

pred cap003310 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003310c { all renamed: CapBenchA | (((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap003310 { cap003310 iff cap003310c }
check CapBenchEquivalent_cap003310 for 4

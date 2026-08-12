var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv12 {
eventually (some f : Trash | always f in Trash)
}

pred inv12c {
	eventually some f : File | always f in Trash
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003478 { all x: CapBenchA | (x->x in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or some CapBenchB) and no CapBenchA)) }
pred cap003478c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003478 { cap003478 iff cap003478c }
check CapBenchEquivalent_cap003478 for 4

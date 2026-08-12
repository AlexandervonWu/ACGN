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

pred cap003649 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap003649c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv12 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003649 { cap003649 iff cap003649c }
check CapBenchEquivalent_cap003649 for 4
